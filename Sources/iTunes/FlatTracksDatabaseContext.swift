//
//  FlatTracksDatabaseContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/29/25.
//

import Foundation

struct FlatTracksDatabaseContext: FlatDBEncoderContext {
  let storage: DatabaseStorage
  let loggingToken: String?
  let serializeDatabaseQueries: Bool

  internal init(
    storage: DatabaseStorage, loggingToken: String? = nil, serializeDatabaseQueries: Bool = false
  ) {
    self.storage = storage
    self.loggingToken = loggingToken
    self.serializeDatabaseQueries = serializeDatabaseQueries
  }

  var context: Database.Context {
    Database.Context(storage: storage, loggingToken: loggingToken)
  }

  func insertStatement(_ item: Item) -> Database.Statement { FlatTrackRow.insertStatement(item) }

  func row(for item: Track) -> FlatTrackRow {
    FlatTrackRow(track: item)
  }

  let schema: String = """
    CREATE TABLE tracks (
      itunesid TEXT NOT NULL PRIMARY KEY,
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
