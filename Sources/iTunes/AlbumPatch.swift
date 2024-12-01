//
//  AlbumPatch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

struct AlbumPatch: Codable, Comparable, Hashable, Sendable {
  let invalid: AlbumArtistName
  let valid: AlbumArtistName?

  static func < (lhs: AlbumPatch, rhs: AlbumPatch) -> Bool {
    lhs.invalid.name < rhs.invalid.name
  }
}
