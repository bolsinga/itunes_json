//
//  RowArtist+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

extension RowArtist: SQLBindableInsert {
  static var insertBinding: Database.Statement { RowArtist().insert }
}
