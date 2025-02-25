//
//  FlatDBEncoder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

protocol FlatRow: Sendable {
  var parameters: [Database.Value] { get }
}

protocol FlatDBEncoderContext: Sendable {
  associatedtype Row: FlatRow
  associatedtype Item: Sendable

  var context: Database.Context { get }

  var schema: String { get }

  func insertStatement(_ item: Item) -> Database.Statement

  func row(for item: Item) -> Row
}

private enum EncodeError: Error {
  case errorNoItems
}

struct FlatDBEncoder<Context: FlatDBEncoderContext> {
  let context: Context
  let db: Database

  init(context: Context) throws {
    self.context = context
    self.db = try Database(context: context.context)
  }

  func encode(items: [Context.Item]) async throws {
    guard let firstItem = items.first else { throw EncodeError.errorNoItems }

    let rows = items.map { context.row(for: $0) }

    try await db.transaction { db in
      try db.execute(context.schema)

      let statement = try Database.PreparedStatement(
        sql: context.insertStatement(firstItem), db: db)

      try statement.executeAndClose(db) { statement, db in
        for row in rows {
          try statement.bind(arguments: row.parameters) { db.errorString }
          try statement.execute { db.errorString }
        }
      }
    }
  }

  func close() async {
    await db.close()
  }

  func data() async throws -> Data {
    try await db.data()
  }
}
