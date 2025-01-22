//
//  TrackCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/1/25.
//

import Foundation

struct TrackCorrection: Codable, Comparable, Hashable, Sendable {
  enum Property: Codable, Comparable, Hashable, Sendable {
    case albumTitle(SortableName)
    case trackCount(Int)
    case artistName(SortableName)
    case discCount(Int)
  }

  let songArtistAlbum: SongArtistAlbum
  let correction: Property

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.songArtistAlbum == rhs.songArtistAlbum {
      switch (lhs.correction, rhs.correction) {
      case (.albumTitle(let lht), .albumTitle(let rht)):
        return lht < rht
      case (.trackCount(let lhc), .trackCount(let rhc)):
        return lhc < rhc
      case (.artistName(let lhn), .artistName(let rhn)):
        return lhn < rhn
      case (.discCount(let lhc), .discCount(let rhc)):
        return lhc < rhc
      default:
        return false
      }
    }
    return lhs.songArtistAlbum < rhs.songArtistAlbum
  }
}

extension SongArtistAlbum {
  fileprivate func matchesExcludingAlbumTitle(_ other: SongArtistAlbum) -> Bool {
    songArtist == other.songArtist
  }
}

extension TrackCorrection {
  func matches(_ other: SongArtistAlbum) -> Bool {
    switch correction {
    case .albumTitle(_):
      songArtistAlbum.matchesExcludingAlbumTitle(other)
    case .trackCount(_), .artistName(_), .discCount(_):
      songArtistAlbum == other
    }
  }
}

extension Collection where Element == TrackCorrection {
  func matches(_ other: SongArtistAlbum) -> [Element] {
    self.filter { $0.matches(other) }
  }
}

extension TrackCorrection: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
