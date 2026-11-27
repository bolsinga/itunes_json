//
//  ArchiveState+Apply.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

extension ArchiveState {
  /// Applies one snapshot. A rebuild applies every snapshot oldest first, and an update applies
  /// the newest one to the state the earlier ones left, so both give the same changes.
  ///
  /// The caller gives the snapshots in tag order and does not give one twice.
  mutating func apply(_ snapshot: Tag<[Track]>) -> SnapshotChanges {
    let tag = snapshot.tag

    // Only music is archived, as for the flat databases: podcasts, voice memos, videos, books and
    // the like are left out without a finding.
    let music = snapshot.item.filter(\.isSQLEncodable)

    // A number that is invalid here but was valid before keeps its newest valid value.
    let patched = music.map { $0.filledFromValid(attributes[$0.persistentID]) }
    let reduction = CatalogReduction(Tag(tag: tag, item: patched))
    for track in music {
      attributes[track.persistentID] = CatalogAttributes.newestValid(
        oldestFirst: [
          attributes[track.persistentID] ?? CatalogAttributes(), CatalogAttributes(track),
        ]
      )
    }

    var findings = reduction.findings.map { Finding.catalog($0) }
    findings += reduction.tracks.compilationNoAlbumArtistFindings.map { .album($0) }
    findings += reduction.tracks.albumSplitFindings.map { .album($0) }

    var plays = [PlayRow]()
    var changedStates = [UInt: PlayState]()
    var newAdded = [DateRow]()
    var newReleased = [DateRow]()

    for track in reduction.tracks {
      let id = track.persistentID
      lastSeen[id] = tag

      if let date = track.dateAdded, !date.isEmpty {
        if let first = added[id] {
          if first.differsBeyondQuirk(from: date) {
            findings.append(
              .timeline(
                TimelineFinding(
                  persistentID: id, code: .dateAddedChanged,
                  detail: "first \(first), now \(date)")))
          }
        } else {
          added[id] = date
          newAdded.append(DateRow(persistentID: id, date: date))
        }
      }
      if let date = track.releaseDate, !date.isEmpty, released[id] == nil {
        released[id] = date
        newReleased.append(DateRow(persistentID: id, date: date))
      }

      let before = playStates[id]
      let step = foldPlayObservation(
        before, PlayObservation(count: track.playCount ?? 0, date: track.playDateUTC))
      if step.state != before {
        playStates[id] = step.state
        if let state = step.state { changedStates[id] = state }
      }
      if let play = step.play {
        let total = playTotals[id, default: 0] + play.delta
        playTotals[id] = total
        plays.append(
          PlayRow(persistentID: id, date: play.date, delta: play.delta, count: total, tag: tag))
        if let owner = playDateOwners[play.date], owner != id {
          findings.append(
            .timeline(
              TimelineFinding(
                persistentID: id, code: .sharedPlayDate,
                detail: "\(play.date) is also a play date of \(owner)")))
        } else {
          playDateOwners[play.date] = id
        }
      }
      if let finding = step.finding {
        findings.append(.play(persistentID: id, finding))
      }
    }

    return SnapshotChanges(
      tag: tag, songs: reduction.tracks, plays: plays, playStates: changedStates,
      added: newAdded, released: newReleased, findings: record(findings, tag: tag))
  }

  /// Leaves out a finding that repeats the last one. A finding about a song repeats when the
  /// song's last finding with the same code has the same detail. A finding that is not about a
  /// song repeats when the previous snapshot had it.
  private mutating func record(_ findings: [Finding], tag: String) -> [FindingRecord] {
    var records = [FindingRecord]()
    var other = Set<OtherFindingKey>()
    for finding in findings {
      if let id = finding.persistentID {
        let key = SongFindingKey(persistentID: id, code: finding.code)
        guard lastDetails[key] != finding.detail else { continue }
        lastDetails[key] = finding.detail
      } else {
        let key = OtherFindingKey(code: finding.code, detail: finding.detail)
        other.insert(key)
        guard !activeOtherFindings.contains(key) else { continue }
      }
      records.append(
        FindingRecord(
          tag: tag, persistentID: finding.persistentID, code: finding.code, detail: finding.detail))
    }
    activeOtherFindings = other
    return records
  }
}

extension Track {
  /// Fills each required number that is not valid from the newest valid one, if there is one.
  fileprivate func filledFromValid(_ valid: CatalogAttributes?) -> Track {
    guard let valid, !missingRequiredFields.isEmpty else { return self }
    var track = self
    if trackNumber.positive == nil { track.trackNumber = valid.trackNumber ?? trackNumber }
    if trackCount.positive == nil { track.trackCount = valid.trackCount ?? trackCount }
    if year.positive == nil { track.year = valid.year ?? year }
    if totalTime.positive == nil { track.totalTime = valid.duration ?? totalTime }
    return track
  }
}

extension String {
  /// Two dates differ when they are not the same instant up to the DST quirk. A date that cannot be
  /// read differs if the text differs.
  fileprivate func differsBeyondQuirk(from other: String) -> Bool {
    let formatter = ISO8601DateFormatter()
    guard let lhs = formatter.date(from: self), let rhs = formatter.date(from: other) else {
      return self != other
    }
    switch lhs.compareQuirk(rhs) {
    case .orderedSame, .orderedSameQuirk: return false
    case .orderedAscending, .orderedDescending: return true
    }
  }
}
