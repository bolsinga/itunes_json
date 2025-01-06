//
//  SongArtist.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/24/24.
//

import Foundation

struct SongArtist: Codable, Comparable, Hashable, Sendable {
  let song: SortableName
  let artist: SortableName

  static func < (lhs: SongArtist, rhs: SongArtist) -> Bool {
    if lhs.song == rhs.song {
      return lhs.artist < rhs.artist
    }
    return lhs.song < rhs.song
  }

  init(song: SortableName, artist: SortableName) {
    self.song = song
    self.artist = artist
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let string = try? container.decode(String.self, forKey: .song) {
      self.song = SortableName(name: string)
    } else {
      self.song = try container.decode(SortableName.self, forKey: .song)
    }

    if let string = try? container.decode(String.self, forKey: .artist) {
      self.artist = SortableName(name: string)
    } else {
      self.artist = try container.decode(SortableName.self, forKey: .artist)
    }
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
