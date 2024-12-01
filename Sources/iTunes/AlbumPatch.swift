//
//  AlbumPatch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

public struct AlbumPatch: Codable, Comparable, Hashable, Sendable {
  let invalid: AlbumArtistName
  let valid: AlbumArtistName?

  public init(invalid: AlbumArtistName, valid: AlbumArtistName? = nil) {
    self.invalid = invalid
    self.valid = valid
  }

  public static func < (lhs: AlbumPatch, rhs: AlbumPatch) -> Bool {
    lhs.invalid.name < rhs.invalid.name
  }
}
