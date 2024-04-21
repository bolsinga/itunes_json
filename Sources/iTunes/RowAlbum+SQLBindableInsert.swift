//
//  RowAlbum+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowAlbum: SQLBindableInsert {
  static var insertBinding: Database.Statement { RowAlbum().insert }

  func argumentsForInsert(using ids: [Int64]) throws -> [Database.Value] {
    guard ids.isEmpty else { throw SQLBindingError.noIDsRequired }

    return [
      Database.Value.string(name.name),
      Database.Value.string(name.sorted),
      Database.Value.integer(Int64(trackCount)),
      Database.Value.integer(Int64(discCount)),
      Database.Value.integer(Int64(discNumber)),
      Database.Value.integer(Int64(compilation)),
    ]
  }
}
