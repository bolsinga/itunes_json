//
//  CatalogReduction.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

/// A track a snapshot has, but that lacks a required number (RFC 0004, "Missing values").
struct InvalidCatalogTrack: Hashable, Sendable {
  let persistentID: UInt
  let name: String
  /// The artist and album names, which are empty if the track has none. They tell where to look in
  /// Music.
  let artist: String
  let album: String
  /// What is missing, as `Track.missingRequiredFields` names it.
  let missing: [String]
}

/// The required numbers of one track in one snapshot. A nil is a number that was absent, zero or
/// negative there.
struct CatalogAttributes: Hashable, Codable, Sendable {
  var trackNumber: Int?
  var trackCount: Int?
  var year: Int?
  var duration: Int?

  init(trackNumber: Int? = nil, trackCount: Int? = nil, year: Int? = nil, duration: Int? = nil) {
    self.trackNumber = trackNumber.positive
    self.trackCount = trackCount.positive
    self.year = year.positive
    self.duration = duration.positive
  }

  init(_ track: Track) {
    self.init(
      trackNumber: track.trackNumber, trackCount: track.trackCount, year: track.year,
      duration: track.totalTime)
  }

  /// Given the attributes of a track in each snapshot that has it, oldest first, gives each
  /// attribute from the newest snapshot in which it is valid (RFC 0005, "Newest valid value"). An
  /// attribute that was never valid is nil.
  ///
  /// `CatalogReduction.invalid` is per snapshot. The RFC excludes a track only when it lacks a
  /// number in every snapshot that has it, which is when this still has a nil attribute. Seeing
  /// every snapshot is for the caller to do.
  static func newestValid(oldestFirst snapshots: [CatalogAttributes]) -> CatalogAttributes {
    var merged = CatalogAttributes()
    for attributes in snapshots {
      merged.trackNumber = attributes.trackNumber ?? merged.trackNumber
      merged.trackCount = attributes.trackCount ?? merged.trackCount
      merged.year = attributes.year ?? merged.year
      merged.duration = attributes.duration ?? merged.duration
    }
    return merged
  }
}

/// One snapshot, reduced for the catalog.
struct CatalogReduction: Sendable {
  let tag: String
  /// One valid track for each persistent ID, with artist sort names filled in, ordered by
  /// persistent ID.
  let tracks: [Track]
  /// The tracks left out of `tracks` for a missing number, ordered by persistent ID. Whether such
  /// a track is invalid for good is decided across snapshots (see `CatalogAttributes.newestValid`).
  let invalid: [InvalidCatalogTrack]
  /// Ordered by code, then persistent ID, then detail.
  let findings: [CatalogFinding]
  /// The entry kept for each persistent ID, valid or not, ordered by persistent ID.
  let entries: [Track]

  init(_ snapshot: Tag<[Track]>) {
    var findings = [CatalogFinding]()

    let unique = Self.reduceDuplicates(snapshot.item, findings: &findings)

    var valid = [Track]()
    var invalid = [InvalidCatalogTrack]()
    for track in unique {
      let missing = track.missingRequiredFields
      if missing.isEmpty {
        valid.append(track)
      } else {
        let artist = track.artistName?.name ?? ""
        let album = track.album ?? ""
        invalid.append(
          InvalidCatalogTrack(
            persistentID: track.persistentID, name: track.name, artist: artist, album: album,
            missing: missing))
        findings.append(
          CatalogFinding(
            persistentID: track.persistentID, code: .invalidTrack,
            detail:
              "\"\(track.name)\" by \(artist) on \"\(album)\" has no \(missing.joined(separator: ", "))"
          ))
      }
    }

    self.tag = snapshot.tag
    self.entries = unique
    self.tracks = Self.fillSortNames(valid, findings: &findings)
    self.invalid = invalid
    self.findings = findings.sorted {
      ($0.code, $0.persistentID ?? 0, $0.detail) < ($1.code, $1.persistentID ?? 0, $1.detail)
    }
  }

  /// Keeps the entry with the earliest `dateAdded`, then the smallest `size`, then the first one.
  /// A missing date or size is later or larger than any other.
  private static func reduceDuplicates(_ tracks: [Track], findings: inout [CatalogFinding])
    -> [Track]
  {
    var kept = [UInt: Track]()
    for track in tracks {
      guard let existing = kept[track.persistentID] else {
        kept[track.persistentID] = track
        continue
      }
      let (winner, loser) =
        track.isPreferred(over: existing) ? (track, existing) : (existing, track)
      kept[track.persistentID] = winner
      findings.append(
        CatalogFinding(
          persistentID: track.persistentID, code: .duplicatePersistentID,
          detail: "dropped \(loser.entryDescription), kept \(winner.entryDescription)"))
    }
    return kept.values.sorted { $0.persistentID < $1.persistentID }
  }

  /// An artist's sort name is the one any of its tracks has.
  static func fillSortNames(_ tracks: [Track], findings: inout [CatalogFinding])
    -> [Track]
  {
    var counts = [String: [String: Int]]()  // artist -> sort name -> tracks with it
    var without = [String: Int]()  // artist -> tracks with no sort name
    for track in tracks {
      guard let artist = track.artistName else { continue }
      if artist.sorted.isEmpty {
        without[artist.name, default: 0] += 1
      } else {
        counts[artist.name, default: [:]][artist.sorted, default: 0] += 1
      }
    }

    var chosen = [String: String]()
    for (artist, sortNames) in counts {
      // Most common first, then alphabetical.
      let ranked = sortNames.sorted { ($1.value, $0.key) < ($0.value, $1.key) }
      let used = ranked[0].key
      chosen[artist] = used
      if ranked.count > 1 {
        let all = ranked.map { "\"\($0.key)\" x\($0.value)" }.joined(separator: ", ")
        findings.append(
          CatalogFinding(
            persistentID: nil, code: .sortNameConflict,
            detail: "artist \"\(artist)\" has sort names \(all), used \"\(used)\""))
      }
      let missing = without[artist, default: 0]
      if missing > 0 {
        findings.append(
          CatalogFinding(
            persistentID: nil, code: .sortNameFilled,
            detail:
              "artist \"\(artist)\" sort name \"\(used)\" used for all tracks, \(ranked[0].value) with it and \(missing) without"
          ))
      }
    }

    return tracks.map { track in
      guard let artist = track.artistName, let sortName = chosen[artist.name] else { return track }
      var track = track
      track.sortArtist = sortName
      return track
    }
  }
}

extension Track {
  fileprivate func isPreferred(over other: Track) -> Bool {
    (dateAddedValue, size ?? .max) < (other.dateAddedValue, other.size ?? .max)
  }

  fileprivate var entryDescription: String {
    "\"\(name)\" (added \(dateAdded ?? "none"), size \(size.map(String.init) ?? "none"))"
  }

  /// A missing or unreadable date sorts after every real one.
  private var dateAddedValue: Date {
    guard let dateAdded, let date = dateAdded.iso8601Date else {
      return .distantFuture
    }
    return date
  }
}
