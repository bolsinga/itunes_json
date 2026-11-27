//
//  ArchiveState.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

/// A row to add to `plays`.
struct PlayRow: Hashable, Sendable {
  let persistentID: UInt
  /// The date as the snapshot has it.
  let date: String
  /// The plays since the previous row.
  let delta: Int
  /// The derived total after this row.
  let count: Int
  let tag: String
}

/// A row to add to `added` or `released`.
struct DateRow: Hashable, Sendable {
  let persistentID: UInt
  /// The date as the snapshot has it.
  let date: String
}

/// What applying one snapshot changes. A later step writes it in one transaction.
struct SnapshotChanges: Sendable {
  let tag: String
  /// Every valid track in the snapshot, to set in the catalog, ordered by persistent ID.
  let songs: [Track]
  let plays: [PlayRow]
  /// The play states that are different now, by persistent ID.
  let playStates: [UInt: PlayState]
  let added: [DateRow]
  let released: [DateRow]
  /// The findings to write, after the repeats are left out.
  let findings: [FindingRecord]
}

/// What the archive has to know to apply the next snapshot. It holds no tracks, so it grows with
/// the number of songs and not with the length of the history.
struct ArchiveState: Equatable, Sendable {
  /// The song's last accepted play count and date.
  var playStates = [UInt: PlayState]()
  /// The derived play total of each song, the `count` of its last play row.
  var playTotals = [UInt: Int]()
  var added = [UInt: String]()
  var released = [UInt: String]()
  /// The tag of the newest snapshot that has the song.
  var lastSeen = [UInt: String]()
  /// Each required number from the newest snapshot in which it was valid.
  var attributes = [UInt: CatalogAttributes]()
  /// The first song that has a play at a date.
  var playDateOwners = [String: UInt]()
  /// The detail of the last finding written for a song and code.
  var lastDetails = [SongFindingKey: String]()
  /// The findings that are not about a song, and were in the previous snapshot.
  var activeOtherFindings = Set<OtherFindingKey>()

  struct SongFindingKey: Hashable, Sendable {
    let persistentID: UInt
    let code: String
  }

  struct OtherFindingKey: Hashable, Sendable {
    let code: String
    let detail: String
  }
}
