//
//  RowArtist+SQLBindable.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowArtist: SQLBindableInsert {
  static var insertBinding: String { Self.bound { RowArtist(name: SortableName()).insert } }

  func bindInsert(db: Database, statement: Database.Statement) throws {
    try statement.bind(db: db, count: 2) { index in
      switch index {
      case 1:
        Database.Value.string(name.name)
      case 2:
        Database.Value.string(name.sorted)
      default:
        preconditionFailure()
      }
    }
  }
}
