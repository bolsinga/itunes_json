//
//  SQLBindableStatement.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

protocol SQLBindableStatement {}

extension SQLBindableStatement {
  static func bound(_ item: () -> String) -> String {
    let previous = DefaultStringInterpolation.SQLBindable
    DefaultStringInterpolation.SQLBindable = true
    defer { DefaultStringInterpolation.SQLBindable = previous }
    return item()
  }
}

enum SQLBindingError: Error {
  case noIDsRequired
}

protocol SQLBindableInsert: SQLBindableStatement {
  static var insertBinding: String { get }

  func bindInsert(db: Database, statement: Database.Statement, ids: [Int64]) throws
}
