//
//  AddedTableBuilder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 4/16/25.
//

import Foundation

struct RowAdd: Hashable, Sendable, SQLBindableInsert {
  let itunesid: String
  let date: String

  var insert: Database.Statement {
    "INSERT OR IGNORE INTO added (itunesid, date) VALUES (\(itunesid), \(date));"
  }

  static var insertBinding: Database.Statement { RowAdd(itunesid: String(0), date: "").insert }
}

extension RowAdd {
  init(_ track: Track) {
    self.itunesid = track.songPersistentID
    self.date = track.dateAddedISO8601
  }
}

struct AddedTableBuilder: TableBuilder {
  func schema(constraints: SchemaConstraints) -> String {
    // itunesid is TEXT since UInt is bigger than Int64 in sqlite
    """
    CREATE TABLE IF NOT EXISTS added (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT NOT NULL
    );
    """
  }

  let rows: [RowAdd]
  let argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  internal init(rows: [RowAdd]) {
    self.rows = rows
    self.argumentBuilder = { $0.insert.parameters }
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }
}
