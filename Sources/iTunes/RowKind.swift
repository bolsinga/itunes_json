//
//  RowKind.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowKind: SQLRow {
  @QuoteEscaped private var kind: String

  init(_ kind: String) {
    self.kind = kind
  }

  var insertStatement: String {
    "INSERT INTO kinds (name) VALUES ('\($kind)');"
  }
}
