//
//  Database+CreateTable.swift
//
//
//  Created by Greg Bolsinga on 4/21/24.
//

import Foundation

protocol TableBuilder {
  associatedtype Row: SQLBindableInsert & Hashable & Sendable

  var schema: String { get }
  var rows: [Row] { get }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? { get }
}

extension TableBuilder {
  func arguments(for row: Row) -> [Database.Value] {
    if let argumentBuilder {
      return argumentBuilder(row)
    }
    return []
  }

  func preparedStatement(using db: isolated Database) throws -> Database.PreparedStatement {
    try Database.PreparedStatement(sql: Row.insertBinding, db: db)
  }
}

extension Database.PreparedStatement {
  func insert(_ arguments: [Database.Value], into db: isolated Database) throws -> Int64 {
    let errorStringBuilder = { db.errorString }
    try bind(arguments: arguments, errorStringBuilder: errorStringBuilder)
    try execute(errorStringBuilder)
    return db.lastID
  }
}

extension Database {
  func createTable<B: TableBuilder>(_ builder: B) throws -> [B.Row: Int64] {
    guard !builder.rows.isEmpty else { return [:] }

    return try self.transaction { db in
      try db.execute(builder.schema)

      let statement = try builder.preparedStatement(using: db)
      defer { statement.close() }

      return try builder.rows.reduce(into: [B.Row: Int64](minimumCapacity: builder.rows.count)) {
        $0[$1] = try statement.insert(builder.arguments(for: $1), into: db)
      }
    }
  }
}
