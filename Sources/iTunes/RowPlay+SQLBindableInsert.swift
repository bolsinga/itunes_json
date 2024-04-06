//
//  RowPlay+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/10/24.
//

import Foundation

extension RowPlay: SQLBindableInsert {
  static var insertBinding: String {
    Self.bound { RowPlay().insert(songid: "") }
  }

  func bindInsert(statement: Database.Statement, ids: [Int64], errorStringBuilder: () -> String)
    throws
  {
    guard ids.count == 1 else { throw SQLBindingError.iDsRequired }

    try statement.bind(
      count: 3,
      binder: { index in
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
      }, errorStringBuilder: errorStringBuilder)
  }
}
