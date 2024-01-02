//
//  RowKind.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowKind: SQLRow {
  @QuoteEscaped var kind: String

  var kindSelect: String {
    "SELECT id FROM kinds WHERE name = '\($kind)'"
  }

  var insertStatement: String {
    "INSERT INTO kinds (name) VALUES ('\($kind)');"
  }
}
