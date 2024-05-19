//
//  Database+CreateTable.swift
//
//
//  Created by Greg Bolsinga on 4/21/24.
//

import Foundation

extension Database.Result {
  func insert(_ arguments: [Database.Value], into db: isolated Database) throws -> Int64 {
    try self.execute(with: arguments) { db.errorString }
    return db.lastID
  }
}

extension Database {
  func createTable<T: SQLBindableInsert & Sendable>(
    tableSchema: String, rows: [T], ids: [[Int64]] = []
  )
    async throws -> [T: Int64]
  {
    guard !rows.isEmpty else { return [:] }

    return try self.transaction { db in
      try db.execute(tableSchema)

      let statement = try Statement(sql: T.insertBinding, db: db)
      defer { statement.close() }

      let result = Result(statement: statement)

      let ids = ids.isEmpty ? Array(repeating: [], count: rows.count) : ids

      var lookup = [T: Int64](minimumCapacity: rows.count)
      for (row, ids) in zip(rows, ids) {
        lookup[row] = try result.insert(try row.argumentsForInsert(using: ids), into: db)
      }
      return lookup
    }
  }
}
