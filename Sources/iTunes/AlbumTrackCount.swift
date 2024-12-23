//
//  AlbumTrackCount.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/23/24.
//

import Foundation

struct AlbumTrackCount: Codable, Comparable, Hashable, Sendable {
  let album: AlbumArtistName
  let trackCount: Int?

  static func < (lhs: AlbumTrackCount, rhs: AlbumTrackCount) -> Bool {
    if lhs.album == rhs.album {
      if let lhCount = lhs.trackCount {
        if let rhCount = rhs.trackCount {
          return lhCount < rhCount
        }
        return false
      }
      return rhs.trackCount == nil
    }
    return lhs.album < rhs.album
  }
}

extension AlbumTrackCount: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
