//
//  SongArtistAlbum.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/23/24.
//

import Foundation

struct SongArtistAlbum: Codable, Comparable, Hashable, Sendable {
  let songArtist: SongArtist
  let album: SortableName?

  static func < (lhs: SongArtistAlbum, rhs: SongArtistAlbum) -> Bool {
    if lhs.songArtist == rhs.songArtist {
      if let lhAlbum = lhs.album {
        if let rhAlbum = rhs.album {
          return lhAlbum < rhAlbum
        }
        return true
      }
      return rhs.album == nil
    }
    return lhs.songArtist < rhs.songArtist
  }
}

extension SongArtistAlbum: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
