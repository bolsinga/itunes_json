//
//  RowKind.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowKind: SQLRow {
  let kind: String

  var select: String {
    "(SELECT id FROM kinds WHERE name = \(kind, sqlOptions:.quoted))"
  }

  var insert: String {
    "INSERT INTO kinds (name) VALUES (\(kind, sqlOptions:.quoted));"
  }
}
