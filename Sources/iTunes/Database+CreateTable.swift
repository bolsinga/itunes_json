//
//  Database+CreateTable.swift
//
//
//  Created by Greg Bolsinga on 4/21/24.
//

import Foundation

protocol TableBuilder: Sendable {
  associatedtype Row: SQLBindableInsert & Hashable & Sendable

  func schema(constraints: SchemaConstraints) -> String
  var rows: [Row] { get }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? { get }
  var statements: [Database.Statement] { get }
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
  func createTable<B: TableBuilder>(_ builder: B, schemaConstraints: SchemaConstraints) throws -> [B
    .Row: Int64]
  {
    try self.transaction { db in
      try db.execute(builder.schema(constraints: schemaConstraints))

      let rows = builder.rows
      guard !rows.isEmpty else { return [:] }

      let statement = try builder.preparedStatement(using: db)

      return try statement.executeAndClose(db) { statement, db in
        try rows.reduce(into: [B.Row: Int64](minimumCapacity: rows.count)) {
          $0[$1] = try statement.insert(builder.arguments(for: $1), into: db)
        }
      }
    }
  }
}
