//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowArtist: SQLRow {
  let name: SortableName

  internal var nameOnly: String {
    name.name
  }

  var select: String {
    "(SELECT id FROM artists WHERE name = \(name.name, sql:.quoted))"
  }

  var insert: String {
    "INSERT INTO artists (name, sortname) VALUES (\(name.name, sql:.quoted), \(name.sorted, sql:.quoted));"
  }
}
