//
//  ArtistTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct ArtistTableBuilder: TableBuilder {
  private let strictSchema: String = """
    name TEXT NOT NULL UNIQUE,
    sortname TEXT NOT NULL DEFAULT '',
    CHECK(length(name) > 0),
    CHECK(name != sortname)
    """

  private let laxSchema: String = """
    name TEXT NOT NULL,
    sortname TEXT NOT NULL DEFAULT ''
    """

  func schema(constraints: SchemaConstraints) -> String {
    """
    CREATE TABLE IF NOT EXISTS artists (
      id INTEGER PRIMARY KEY,
      \(constraints == .strict ? strictSchema : laxSchema)
    );
    CREATE TABLE IF NOT EXISTS artistids (
      itunesid TEXT NOT NULL PRIMARY KEY,
      artistid INTEGER NOT NULL
    );
    """
  }

  let rows: [RowArtist]

  init(rows: [RowArtist]) {
    self.rows = rows.sorted(by: { $0.name < $1.name })
  }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? {
    { $0.insert.parameters }
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }
}
