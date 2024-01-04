//
//  SQLRow.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol SQLStatement {}

protocol SQLSelectID: SQLStatement {
  var selectID: String { get }
}

protocol SQLInsert: SQLStatement {
  var insert: String { get }
}

protocol SQLRow: Hashable {}
