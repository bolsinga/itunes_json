//
//  RowArtist+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowArtist: SQLBindableInsert {
  static var insertBinding: String { Self.bound { RowArtist().insert } }

  func bindInsert(statement: Database.Statement, ids: [Int64], errorStringBuilder: () -> String)
    throws
  {
    guard ids.isEmpty else { throw SQLBindingError.noIDsRequired }

    try statement.bind(
      count: 2,
      binder: { index in
        switch index {
        case 1:
          Database.Value.string(name.name)
        case 2:
          Database.Value.string(name.sorted)
        default:
          preconditionFailure()
        }
      }, errorStringBuilder: errorStringBuilder)
  }
}
