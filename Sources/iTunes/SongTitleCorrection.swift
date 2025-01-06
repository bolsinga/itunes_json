//
//  SongTitleCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/6/25.
//

import Foundation

struct SongTitleCorrection: Codable, Comparable, Hashable, Sendable {
  let song: SongIdentifier
  let correctedTitle: SortableName

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.song == rhs.song {
      return lhs.correctedTitle < rhs.correctedTitle
    }
    return lhs.song < rhs.song
  }
}

extension SongTitleCorrection: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
