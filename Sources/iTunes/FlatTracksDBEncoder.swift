//
//  FlatTracksDBEncoder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

protocol FlatTracksDBEncoderContext {
  var context: Database.Context { get }
}

struct FlatTracksDBEncoder<Context: FlatTracksDBEncoderContext> {
  let db: Database

  init(context: Context) throws {
    self.db = try Database(context: context.context)
  }

  func encode(tracks: [Track]) async throws {
    let rows = tracks.map { FlatTrackRow(track: $0) }

    try await db.transaction { db in
      try db.execute(schema)

      let statement = try Database.PreparedStatement(sql: FlatTrackRow.insertStatement, db: db)

      try statement.executeAndClose(db) { statement, db in
        for row in rows {
          try statement.bind(arguments: row.insert.parameters) { db.errorString }
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

  private var schema: String = """
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY,
      itunesid TEXT NOT NULL,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      artist TEXT NOT NULL,
      sortartist TEXT NOT NULL DEFAULT '',
      album TEXT NOT NULL,
      sortalbum TEXT NOT NULL DEFAULT '',
      tracknumber INTEGER NOT NULL,
      trackcount INTEGER NOT NULL,
      disccount INTEGER NOT NULL,
      discnumber INTEGER NOT NULL,
      year INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      dateadded TEXT NOT NULL,
      compilation INTEGER NOT NULL,
      composer TEXT NOT NULL DEFAULT '',
      datereleased TEXT NOT NULL DEFAULT '',
      comments TEXT NOT NULL DEFAULT '',
      playdate TEXT NOT NULL,
      playcount INTEGER NOT NULL
    );
    """
}
