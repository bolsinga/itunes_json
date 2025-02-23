//
//  SongIdentifier.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/6/25.
//

import Foundation

struct SongIdentifier: Codable, Comparable, Hashable, Sendable {
  let song: SongArtistAlbum
  let persistentID: UInt

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.song == rhs.song {
      return lhs.persistentID < rhs.persistentID
    }
    return lhs.song < rhs.song
  }
}

extension SongIdentifier: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
