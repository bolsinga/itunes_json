//
//  SQLBindableStatement.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation

protocol SQLBindableStatement {}

enum SQLBindingError: Error {
  case noIDsRequired
  case iDsRequired
}

protocol SQLBindableInsert: SQLBindableStatement {
  static var insertBinding: Database.Statement { get }

  func argumentsForInsert(using ids: [Int64]) throws -> [Database.Value]
}
