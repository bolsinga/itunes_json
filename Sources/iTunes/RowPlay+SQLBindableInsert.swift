//
//  RowPlay+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/10/24.
//

import Foundation

extension RowPlay: SQLBindableInsert {
  static var insertBinding: Database.Statement { RowPlay().insert(songid: .empty) }

  func argumentsForInsert(using ids: [Int64]) throws -> [Database.Value] {
    guard ids.count == 1 else { throw SQLBindingError.iDsRequired }

    return [
      Database.Value.string(date),
      Database.Value.integer(Int64(delta)),
      Database.Value.integer(ids[0]),
    ]
  }
}
