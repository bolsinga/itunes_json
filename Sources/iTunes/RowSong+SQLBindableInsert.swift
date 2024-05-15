//
//  RowSong+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/9/24.
//

import Foundation

extension RowSong: SQLBindableInsert {
  static var insertBinding: String {
    Self.bound { RowSong().insert(artistID: "", albumID: "") }
  }

  func argumentsForInsert(using ids: [Int64]) throws -> [Database.Value] {
    guard ids.count == 2 else { throw SQLBindingError.iDsRequired }

    return [
      Database.Value.string(name.name),
      Database.Value.string(name.sorted),
      Database.Value.string(String(itunesid)),
      Database.Value.string(String(composer)),
      Database.Value.integer(Int64(trackNumber)),
      Database.Value.integer(Int64(year)),
      Database.Value.integer(Int64(duration)),
      Database.Value.string(dateAdded),
      Database.Value.string(dateReleased),
      Database.Value.string(comments),
      Database.Value.integer(ids[0]),
      Database.Value.integer(ids[1]),
    ]
  }
}
