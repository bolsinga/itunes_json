//
//  RowPlay+SQLBindable.swift
//
//
//  Created by Greg Bolsinga on 1/10/24.
//

import Foundation

extension RowPlay: SQLBindableInsert {
  static var insertBinding: String {
    Self.bound { RowPlay(date: "", delta: 0).insert(songid: "") }
  }

  func bindInsert(db: Database, statement: Database.Statement, ids: [Int64]) throws {
    guard ids.count == 1 else { throw SQLBindingError.iDsRequired }

    try statement.bind(db: db, count: 3) { index in
      switch index {
      case 1:
        Database.Value.string(date)
      case 2:
        Database.Value.integer(Int64(delta))
      case 3:
        Database.Value.integer(ids[0])
      default:
        preconditionFailure()
      }
    }
  }
}
