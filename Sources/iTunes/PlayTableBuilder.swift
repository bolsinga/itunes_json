//
//  PlayTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct PlayTableBuilder: TableBuilder {
  private let strictSchema: String = """
    UNIQUE(itunesid, date, delta),
    UNIQUE(date),
    FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
    CHECK(length(date) > 0),
    CHECK(delta > 0)
    """

  private let laxSchema: String = """
    FOREIGN KEY(itunesid) REFERENCES songs(itunesid)
    """

  let tracks: [TrackRow]

  func schema(constraints: SchemaConstraints) -> String {
    """
    CREATE TABLE IF NOT EXISTS plays (
      id INTEGER PRIMARY KEY,
      itunesid TEXT NOT NULL,
      date TEXT NOT NULL,
      delta INTEGER NOT NULL,
      \(constraints == .strict ? strictSchema : laxSchema)
    );
    """
  }

  var rows: [RowPlay] { tracks.map { $0.play! } }
  var argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  init(tracks: [TrackRow]) {
    self.tracks = tracks.sorted(by: { $0.play!.date < $1.play!.date })
    self.argumentBuilder = { $0.insert.parameters }
  }

  var statements: [Database.Statement] {
    tracks.map { $0.play!.insert }
  }
}
