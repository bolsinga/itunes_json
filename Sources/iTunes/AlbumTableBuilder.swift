//
//  AlbumTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct AlbumTableBuilder: TableBuilder {
  private let strictSchema: String = """
    CHECK(length(name) > 0),
    CHECK(name != sortname),
    CHECK(trackcount > 0),
    """

  func schema(constraints: SchemaConstraints) -> String {
    """
    CREATE TABLE albums (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      trackcount INTEGER NOT NULL,
      disccount INTEGER NOT NULL,
      discnumber INTEGER NOT NULL,
      compilation INTEGER NOT NULL,
      UNIQUE(name, trackcount, disccount, discnumber, compilation),
      \(constraints == .strict ? strictSchema : "")
      CHECK(disccount > 0),
      CHECK(discnumber > 0),
      CHECK(compilation = 0 OR compilation = 1)
    );
    """
  }

  let rows: [RowAlbum]

  init(rows: [RowAlbum]) {
    self.rows = rows.sorted(by: { $0.name < $1.name })
  }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? {
    { $0.insert.parameters }
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }
}
