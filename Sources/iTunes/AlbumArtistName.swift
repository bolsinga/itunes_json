//
//  AlbumArtistName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/24.
//

import Foundation

public struct AlbumArtistName: Codable, Comparable, Hashable, Sendable {
  enum AlbumType: Codable, Hashable {
    case compilation
    case artist(String)
    case unknown

    func isSimilar(to other: AlbumType) -> Bool {
      // self is current here
      switch (self, other) {
      case (.compilation, .compilation):
        return true
      case (.artist(let sa), .artist(let oa)):
        return sa.isSimilar(to: oa)
      case (.unknown, .unknown):
        return true
      case (.compilation, .artist(_)):
        // self says it is a compilation, but the old code says it is not. trust the current version.
        return true
      default:
        return false
      }
    }
  }

  let name: SortableName
  let type: AlbumType

  public static func < (lhs: AlbumArtistName, rhs: AlbumArtistName) -> Bool {
    lhs.name < rhs.name
  }
}

extension AlbumArtistName: CustomStringConvertible {
  public var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
