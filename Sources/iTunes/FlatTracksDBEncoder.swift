//
//  FlatTracksDBEncoder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

protocol FlatRow: Sendable {
  var parameters: [Database.Value] { get }
}

protocol FlatTracksDBEncoderContext: Sendable {
  associatedtype Row: FlatRow

  var context: Database.Context { get }

  var schema: String { get }

  var insertStatement: Database.Statement { get }

  func row(for track: Track) -> Row
}

struct FlatTracksDBEncoder<Context: FlatTracksDBEncoderContext> {
  let context: Context
  let db: Database

  init(context: Context) throws {
    self.context = context
    self.db = try Database(context: context.context)
  }

  func encode(tracks: [Track]) async throws {
    let rows = tracks.map { context.row(for: $0) }

    try await db.transaction { db in
      try db.execute(context.schema)

      let statement = try Database.PreparedStatement(sql: context.insertStatement, db: db)

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
