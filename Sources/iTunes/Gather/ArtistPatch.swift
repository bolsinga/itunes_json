//
//  ArtistPatch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/20/24.
//

import Foundation

struct ArtistPatch: Codable, Comparable, Hashable, Sendable {
  let invalid: SortableName
  let valid: SortableName?

  static func < (lhs: ArtistPatch, rhs: ArtistPatch) -> Bool {
    lhs.invalid < rhs.invalid
  }
}
