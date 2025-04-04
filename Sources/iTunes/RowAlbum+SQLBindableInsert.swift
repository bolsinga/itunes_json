//
//  RowAlbum+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowAlbum: SQLBindableInsert {
  static var insertBinding: Database.Statement { RowAlbum().insert(artistID: .empty) }
}
