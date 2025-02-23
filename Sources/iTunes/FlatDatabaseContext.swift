//
//  FlatDatabaseContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/29/25.
//

import Foundation

struct FlatDatabaseContext: FlatTracksDBEncoderContext {
  let storage: DatabaseStorage
  let loggingToken: String?

  var context: Database.Context {
    Database.Context(storage: storage, loggingToken: loggingToken)
  }

  var insertStatement: Database.Statement { FlatTrackRow.insertStatement }

  func row(for track: Track) -> FlatTrackRow {
    FlatTrackRow(track: track)
  }

  var schema: String = """
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
