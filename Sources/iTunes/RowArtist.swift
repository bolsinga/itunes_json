//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowArtistInterface {
  var artistName: SortableName { get }
}

struct RowArtist: Hashable {
  let name: SortableName

  init(_ artist: RowArtistInterface) {
    self.init(name: artist.artistName)
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
