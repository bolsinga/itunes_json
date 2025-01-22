//
//  TrackIdentifier.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/22/25.
//

import Foundation

extension Optional where Wrapped == Int {
  fileprivate static func < (lhs: Self, rhs: Self) -> Bool {
    if let lhs, let rhs {
      return lhs < rhs
    }
    return lhs == nil && rhs == nil
  }
}

struct TrackIdentifier: Codable, Comparable, Hashable, Sendable {
  let songIdentifier: SongIdentifier
  let trackNumber: Int?
  let trackCount: Int?
  let discNumber: Int?
  let discCount: Int?

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.songIdentifier == rhs.songIdentifier {
      return lhs.songIdentifier < rhs.songIdentifier
    }

    if lhs.discCount == rhs.discCount {
      if lhs.discNumber == rhs.discNumber {
        if lhs.trackCount == rhs.trackCount {
          return lhs.trackNumber < rhs.trackNumber
        }
        return lhs.trackCount < rhs.trackCount
      }
      return lhs.discNumber < rhs.discNumber
    }
    return lhs.discCount < rhs.discCount
  }
}

extension TrackIdentifier: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}

extension TrackIdentifier {
  func matchesSongIdentifier(_ other: Self) -> Bool {
    songIdentifier == other.songIdentifier
  }
}
