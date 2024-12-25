//
//  SongArtist.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/24/24.
//

import Foundation

struct SongArtist: Codable, Comparable, Hashable, Sendable {
  let song: String
  let artist: String

  static func < (lhs: SongArtist, rhs: SongArtist) -> Bool {
    if lhs.song == rhs.song {
      return lhs.artist < rhs.artist
    }
    return lhs.song < rhs.song
  }
}

extension SongArtist: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
