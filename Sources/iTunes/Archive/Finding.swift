//
//  Finding.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

enum TimelineFindingCode: String, Sendable {
  case dateAddedChanged
  case sharedPlayDate
}

/// What the timeline rules noticed about one song. See RFC 0005, "Shared play dates" and "Date
/// added and date released".
struct TimelineFinding: Hashable, Sendable {
  let persistentID: UInt
  let code: TimelineFindingCode
  let detail: String
}

/// Any finding the archive step can give. Each case keeps the type of the rules that wrote it.
enum Finding: Equatable, Sendable {
  case play(persistentID: UInt, PlayFinding)
  case catalog(CatalogFinding)
  case album(AlbumFinding)
  case timeline(TimelineFinding)

  /// The song the finding is about. Nil when it is about an artist or an album.
  var persistentID: UInt? {
    switch self {
    case .play(let id, _): id
    case .catalog(let finding): finding.persistentID
    case .album(let finding): finding.persistentID
    case .timeline(let finding): finding.persistentID
    }
  }

  /// The code as it is written to the `findings` table.
  var code: String {
    switch self {
    case .play(_, let finding): finding.code.rawValue
    case .catalog(let finding): finding.code.rawValue
    case .album(let finding): finding.code.rawValue
    case .timeline(let finding): finding.code.rawValue
    }
  }

  /// The detail as it is written to the `findings` table. It never holds the tag, so that two
  /// findings that differ only by tag have the same detail.
  var detail: String {
    switch self {
    case .play(_, let finding): finding.detail
    case .catalog(let finding): finding.detail
    case .album(let finding): finding.detail
    case .timeline(let finding): finding.detail
    }
  }
}

/// A row of the `findings` table.
struct FindingRecord: Hashable, Sendable {
  let tag: String
  let persistentID: UInt?
  let code: String
  let detail: String
}

extension PlayState {
  fileprivate var text: String { "(\(seenCount), \(seenDate.isEmpty ? "none" : seenDate))" }
}

extension PlayFinding {
  /// What is needed to apply the observation differently later: the state before, the observation,
  /// and what the fold did.
  var detail: String {
    "before=\(before?.text ?? "none") observation=(\(observation.count), \(observation.date ?? "none")) playsAdded=\(playsAdded) after=\(after?.text ?? "none")"
  }
}
