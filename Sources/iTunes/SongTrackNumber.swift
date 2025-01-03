//
//  SongTrackNumber.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct SongTrackNumber: Codable, Comparable, Hashable, Sendable {
  let song: SongArtistAlbum
  let trackNumber: Int?

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.song == rhs.song {
      if let lhNumber = lhs.trackNumber {
        if let rhNumber = rhs.trackNumber {
          return lhNumber < rhNumber
        }
        return false
      }
      return rhs.trackNumber == nil
    }
    return lhs.song < rhs.song
  }
}

extension SongTrackNumber: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
