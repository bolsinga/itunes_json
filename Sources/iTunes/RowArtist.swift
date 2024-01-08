//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowArtist: TrackRowItem {
  let name: SortableName

  internal var nameOnly: String {
    name.name
  }
}

extension RowArtist: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM artists WHERE name = \(sql: name.name, options:.safeQuoted))"
  }
}

extension RowArtist: SQLInsert {
  var insert: String {
    "INSERT INTO artists (name, sortname) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted));"
  }
}
