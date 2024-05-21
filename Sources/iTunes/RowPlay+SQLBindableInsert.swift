//
//  RowPlay+SQLBindableInsert.swift
//
//
//  Created by Greg Bolsinga on 1/10/24.
//

import Foundation

extension RowPlay: SQLBindableInsert {
  static var insertBinding: Database.Statement { RowPlay().insert(songid: .empty) }
}
