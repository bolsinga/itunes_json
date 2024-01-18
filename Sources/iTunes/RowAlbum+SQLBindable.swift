//
//  RowAlbum+SQLBindable.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowAlbum: SQLBindableInsert {
  static var insertBinding: String {
    Self.bound { RowAlbum().insert }
  }

  func bindInsert(db: Database, statement: Database.Statement, ids: [Int64]) throws {
    guard ids.isEmpty else { throw SQLBindingError.noIDsRequired }

    try statement.bind(db: db, count: 6) { index in
      switch index {
      case 1:
        Database.Value.string(name.name)
      case 2:
        Database.Value.string(name.sorted)
      case 3:
        Database.Value.integer(Int64(trackCount))
      case 4:
        Database.Value.integer(Int64(discCount))
      case 5:
        Database.Value.integer(Int64(discNumber))
      case 6:
        Database.Value.integer(Int64(compilation))
      default:
        preconditionFailure()
      }
    }
  }
}
