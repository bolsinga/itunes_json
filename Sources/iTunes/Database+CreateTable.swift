//
//  Database+CreateTable.swift
//
//
//  Created by Greg Bolsinga on 4/21/24.
//

import Foundation

extension Database.PreparedStatement {
  func insert(_ arguments: [Database.Value], into db: isolated Database) throws -> Int64 {
    let errorStringBuilder = { db.errorString }
    try bind(arguments: arguments, errorStringBuilder: errorStringBuilder)
    try execute(errorStringBuilder)
    return db.lastID
  }
}

extension Database {
  func createTable<T: SQLBindableInsert & Sendable>(
    tableSchema: String, rows: [T], arguments: @Sendable (T) -> [Database.Value]
  ) throws -> [T: Int64] {
    guard !rows.isEmpty else { return [:] }

    return try self.transaction { db in
      try db.execute(tableSchema)

      let statement = try PreparedStatement(sql: T.insertBinding, db: db)
      defer { statement.close() }

      return try rows.reduce(into: [T: Int64](minimumCapacity: rows.count)) {
        $0[$1] = try statement.insert(arguments($1), into: db)
      }
    }
  }
}
