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
    for track in reduction.entries {
      attributes[track.persistentID] = CatalogAttributes.newestValid(
        oldestFirst: [
          attributes[track.persistentID] ?? CatalogAttributes(), CatalogAttributes(track),
        ]
      )
    }

    var findings = reduction.findings.map { (Finding.catalog($0), tag) }
    findings += reduction.tracks.compilationNoAlbumArtistFindings.map { (.album($0), tag) }
    findings += reduction.tracks.albumSplitFindings.map { (.album($0), tag) }

    // A track that is not valid yet is kept, until it is.
    let invalidIDs = Set(reduction.invalid.map(\.persistentID))
    for track in reduction.entries where invalidIDs.contains(track.persistentID) {
      keepPending(track, tag: tag)
    }

    var folded = Folded()
    var newAdded = [DateRow]()
    var newReleased = [DateRow]()

    for track in reduction.tracks {
      let id = track.persistentID
      lastSeen[id] = tag

      // What the track showed while it was not valid happened first.
      let waiting = pending.removeValue(forKey: id)
      if let waiting {
        if added[id] == nil, let date = waiting.added {
          added[id] = date
          newAdded.append(DateRow(persistentID: id, date: date))
        }
        if released[id] == nil, let date = waiting.released {
          released[id] = date
          newReleased.append(DateRow(persistentID: id, date: date))
        }
      }

      if let date = track.dateAdded, !date.isEmpty {
        if let first = added[id] {
          if first.differsBeyondQuirk(from: date) {
            findings.append(
              (
                .timeline(
                  TimelineFinding(
                    persistentID: id, code: .dateAddedChanged,
                    detail: "first \(first), now \(date)")), tag
              ))
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

      for observation in waiting?.observations ?? [] {
        fold(
          PlayObservation(count: observation.count, date: observation.date), of: id,
          tag: observation.tag, into: &folded)
      }
      fold(
        PlayObservation(count: track.playCount ?? 0, date: track.playDateUTC), of: id, tag: tag,
        into: &folded)
    }

    let records = record(findings + folded.findings, tag: tag)
    return SnapshotChanges(
      tag: tag, songs: reduction.tracks, plays: folded.plays, playStates: folded.states,
      added: newAdded, released: newReleased, findings: records,
      activeOtherFindings: activeOtherFindings.sorted {
        ($0.code, $0.detail) < ($1.code, $1.detail)
      },
      partialAttributes: attributes.filter { lastSeen[$0.key] == nil }, pending: pending)
  }

  /// The rows and findings that folding observations gives.
  private struct Folded {
    var plays = [PlayRow]()
    var states = [UInt: PlayState]()
    var findings = [(Finding, String)]()
  }

  /// Folds one observation of a song that was made at `tag`.
  private mutating func fold(
    _ observation: PlayObservation, of id: UInt, tag: String, into folded: inout Folded
  ) {
    let before = playStates[id]
    let step = foldPlayObservation(before, observation)
    if step.state != before {
      playStates[id] = step.state
      if let state = step.state { folded.states[id] = state }
    }
    if let play = step.play {
      let total = playTotals[id, default: 0] + play.delta
      playTotals[id] = total
      folded.plays.append(
        PlayRow(persistentID: id, date: play.date, delta: play.delta, count: total, tag: tag))
      if let owner = playDateOwners[play.date], owner != id {
        folded.findings.append(
          (
            .timeline(
              TimelineFinding(
                persistentID: id, code: .sharedPlayDate,
                detail: "\(play.date) is also a play date of \(owner)")), tag
          ))
      } else {
        playDateOwners[play.date] = id
      }
    }
    if let finding = step.finding {
      folded.findings.append((.play(persistentID: id, finding), tag))
    }
  }

  /// Keeps what an invalid track shows, when it is different from the last time.
  private mutating func keepPending(_ track: Track, tag: String) {
    var entry = pending[track.persistentID] ?? PendingTrack()
    if entry.added == nil, let date = track.dateAdded, !date.isEmpty { entry.added = date }
    if entry.released == nil, let date = track.releaseDate, !date.isEmpty {
      entry.released = date
    }
    let observation = PendingTrack.Observation(
      tag: tag, count: track.playCount ?? 0, date: track.playDateUTC)
    if let last = entry.observations.last {
      if (last.count, last.date) != (observation.count, observation.date) {
        entry.observations.append(observation)
      }
    } else if observation.count != 0 || !(observation.date ?? "").isEmpty {
      entry.observations.append(observation)
    }
    pending[track.persistentID] = entry
  }

  /// Leaves out a finding that repeats the last one. A finding about a song repeats when the
  /// song's last finding with the same code has the same detail. A finding that is not about a
  /// song repeats when the previous snapshot had it.
  private mutating func record(_ findings: [(Finding, String)], tag: String)
    -> [FindingRecord]
  {
    var records = [FindingRecord]()
    var other = Set<OtherFindingKey>()
    for (finding, tag) in findings {
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
    if self == other { return false }
    guard let lhs = iso8601Date, let rhs = other.iso8601Date else {
      return true
    }
    switch lhs.compareQuirk(rhs) {
    case .orderedSame, .orderedSameQuirk: return false
    case .orderedAscending, .orderedDescending: return true
    }
  }
}
