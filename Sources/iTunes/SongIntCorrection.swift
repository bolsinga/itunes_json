//
//  SongIntCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct SongIntCorrection: Codable, Comparable, Hashable, Sendable {
  let song: SongArtistAlbum
  let value: Int?

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.song == rhs.song {
      if let lhValue = lhs.value {
        if let rhValue = rhs.value {
          return lhValue < rhValue
        }
        return false
      }
      return rhs.value == nil
    }
    return lhs.song < rhs.song
  }
}

extension SongIntCorrection: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
