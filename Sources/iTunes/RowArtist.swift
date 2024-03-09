//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation
import os

protocol RowArtistInterface {
  func artistName(logger: Logger) -> SortableName
}

struct RowArtist: Hashable {
  let name: SortableName

  init(_ artist: RowArtistInterface, validation: TrackValidation) {
    self.init(name: artist.artistName(logger: validation.noArtist))
  }

  init() {
    self.init(name: SortableName())
  }

  private init(name: SortableName) {
    self.name = name
  }

  internal var nameOnly: String {
    name.name
  }

  var selectID: String {
    "(SELECT id FROM artists WHERE name = \(sql: name.name, options:.safeQuoted))"
  }

  var insert: String {
    "INSERT INTO artists (name, sortname) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted));"
  }
}
