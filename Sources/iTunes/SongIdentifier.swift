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

extension SongArtist {
  fileprivate func matchesExcludingSongName(_ other: Self) -> Bool {
    artist == other.artist
  }
}

extension SongArtistAlbum {
  fileprivate func matchesExcludingSongName(_ other: Self) -> Bool {
    songArtist.matchesExcludingSongName(other.songArtist) && album == other.album
  }
}

extension SongIdentifier {
  func matchesExcludingSongName(_ other: Self) -> Bool {
    song.matchesExcludingSongName(other.song) && persistentID == other.persistentID
  }
}
