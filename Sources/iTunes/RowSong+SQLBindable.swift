//
//  RowSong+SQLBindable.swift
//
//
//  Created by Greg Bolsinga on 1/9/24.
//

import Foundation

extension RowSong: SQLBindableInsert {
  static var insertBinding: String {
    Self.bound { RowSong().insert(artistID: "", albumID: "") }
  }

  func bindInsert(db: Database, statement: Database.Statement, ids: [Int64]) throws {
    guard ids.count == 2 else { throw SQLBindingError.iDsRequired }

    try statement.bind(db: db, count: 12) { index in
      switch index {
      case 1:
        Database.Value.string(name.name)
      case 2:
        Database.Value.string(name.sorted)
      case 3:
        Database.Value.string(String(itunesid))
      case 4:
        Database.Value.string(String(composer))
      case 5:
        Database.Value.integer(Int64(trackNumber))
      case 6:
        Database.Value.integer(Int64(year))
      case 7:
        Database.Value.integer(Int64(duration))
      case 8:
        Database.Value.string(dateAdded)
      case 9:
        Database.Value.string(dateReleased)
      case 10:
        Database.Value.string(comments)
      case 11:
        Database.Value.integer(ids[0])
      case 12:
        Database.Value.integer(ids[1])
      default:
        preconditionFailure()
      }
    }
  }
}
