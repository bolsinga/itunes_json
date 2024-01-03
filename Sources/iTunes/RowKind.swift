//
//  RowKind.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowKind: SQLRow {
  @QuoteEscaped var kind: String

  var select: String {
    "SELECT id FROM kinds WHERE name = \($kind)"
  }

  var insert: String {
    "INSERT INTO kinds (name) VALUES (\($kind));"
  }
}
