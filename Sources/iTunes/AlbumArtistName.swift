//
//  AlbumArtistName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/24.
//

struct AlbumArtistName: Codable, Hashable, Sendable {
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
}
