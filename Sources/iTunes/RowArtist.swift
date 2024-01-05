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
}

extension RowArtist: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM artists WHERE name = \(name.name, sql:.safeQuoted))"
  }
}

extension RowArtist: SQLInsert {
  var insert: String {
    "INSERT INTO artists (name, sortname) VALUES (\(name.name, sql:.safeQuoted), \(name.sorted, sql:.safeQuoted));"
  }
}
