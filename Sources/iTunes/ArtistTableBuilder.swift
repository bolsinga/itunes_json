//
//  ArtistTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct ArtistTableBuilder: TableBuilder {
  private let ArtistTable = """
    CREATE TABLE artists (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      sortname TEXT NOT NULL DEFAULT '',
      CHECK(length(name) > 0),
      CHECK(name != sortname)
    );
    """

  var schema: String { ArtistTable }
  let rows: [RowArtist]

  init(rows: [RowArtist]) {
    self.rows = rows.sorted(by: { $0.name < $1.name })
  }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? {
    { $0.insert.parameters }
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }
}
