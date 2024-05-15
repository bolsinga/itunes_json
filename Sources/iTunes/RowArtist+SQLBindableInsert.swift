//
//  RowArtist+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowArtist: SQLBindableInsert {
  static var insertBinding: String { Self.bound { RowArtist().insert } }

  func argumentsForInsert(using ids: [Int64]) throws -> [Database.Value] {
    guard ids.isEmpty else { throw SQLBindingError.noIDsRequired }

    return [
      Database.Value.string(name.name),
      Database.Value.string(name.sorted),
    ]
  }
}
