//
//  RowKind+SQLBindable.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowKind: SQLBindableInsert {
  static var insertBinding: String { Self.bound { RowKind(kind: "").insert } }

  func bindInsert(db: Database, statement: Database.Statement) throws {
    try statement.bind(db: db, count: 1) { _ in
      Database.Value.string(self.kind)
    }
  }
}
