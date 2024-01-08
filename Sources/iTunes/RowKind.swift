//
//  RowKind.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowKind: TrackRowItem {
  let kind: String
}

extension RowKind: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM kinds WHERE name = \(sql: kind, options:.safeQuoted))"
  }
}

extension RowKind: SQLInsert {
  var insert: String {
    "INSERT INTO kinds (name) VALUES (\(sql: kind, options:.safeQuoted));"
  }
}
