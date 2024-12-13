//
//  AlbumArtistName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/24.
//

import Foundation

struct AlbumArtistName: Codable, Comparable, Hashable, Sendable {
  enum AlbumType: Codable, Hashable {
    case compilation(String?)
    case artist(String)
    case unknown

    func isSimilar(to other: AlbumType) -> Bool {
      // self is current here
      switch (self, other) {
      case (.compilation(let sa), .compilation(let oa)):
        guard let sa, let oa else { return false }
        return sa.isSimilar(to: oa)
      case (.artist(let sa), .artist(let oa)):
        return sa.isSimilar(to: oa)
      case (.unknown, .unknown):
        return true
      case (.artist(let sa), .compilation(let oa)):
        /// No equivalent in reverse, as that will remove fixes.
        guard let oa else { return false }
        return sa.isSimilar(to: oa)
      default:
        return false
      }
    }

    var artist: String? {
      switch self {
      case .compilation(let artist):
        artist
      case .artist(let artist):
        artist
      case .unknown:
        nil
      }
    }

    var isCompilation: Bool {
      switch self {
      case .compilation(_):
        true
      case .artist(_), .unknown:
        false
      }
    }
  }

  let name: SortableName
  let type: AlbumType

  static func < (lhs: AlbumArtistName, rhs: AlbumArtistName) -> Bool {
    lhs.name < rhs.name
  }

  func update(name: String) -> AlbumArtistName {
    AlbumArtistName(name: SortableName(name: name), type: self.type)
  }

  func updateToCompilation() -> AlbumArtistName {
    AlbumArtistName(name: name, type: .compilation(type.artist))
  }
}

extension AlbumArtistName: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
