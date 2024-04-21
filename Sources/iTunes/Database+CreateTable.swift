//
//  Database+CreateTable.swift
//
//
//  Created by Greg Bolsinga on 4/21/24.
//

import Foundation

extension Database {
  func createTable<T: SQLBindableInsert & Sendable>(table: String, rows: [T], ids: [[Int64]] = [])
    async throws -> [T: Int64]
  {
    guard !rows.isEmpty else { return [:] }

    return try self.transaction { db in
      try db.execute(table)

      let statement = try db.prepare(T.insertBinding)

      let ids = ids.isEmpty ? Array(repeating: [], count: rows.count) : ids

      let errorStringBuilder = { db.errorString }

      var lookup = [T: Int64](minimumCapacity: rows.count)
      for (row, ids) in zip(rows, ids) {
        try row.bindInsert(statement: statement, ids: ids, errorStringBuilder: errorStringBuilder)
        try statement.execute(errorStringBuilder)
        lookup[row] = db.lastID
      }
      return lookup
    }
  }
}
