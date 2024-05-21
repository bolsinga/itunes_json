//
//  RowSong+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/9/24.
//

import Foundation

extension RowSong: SQLBindableInsert {
  static var insertBinding: Database.Statement {
    RowSong().insert(artistID: .empty, albumID: .empty)
  }
}
