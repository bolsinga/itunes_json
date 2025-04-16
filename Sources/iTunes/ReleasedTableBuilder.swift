//
//  ReleasedTableBuilder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 4/16/25.
//

import Foundation

struct RowRelease: Hashable, Sendable, SQLBindableInsert {
  let itunesid: String
  let date: String

  var insert: Database.Statement {
    "INSERT OR IGNORE INTO released (itunesid, date) VALUES (\(itunesid), \(date));"
  }

  static var insertBinding: Database.Statement { RowRelease(itunesid: String(0), date: "").insert }
}

extension RowRelease {
  init(_ track: Track) {
    self.itunesid = track.songPersistentID
    self.date = track.dateReleasedISO8601
  }
}

struct ReleasedTableBuilder: TableBuilder {
  func schema(constraints: SchemaConstraints) -> String {
    // itunesid is TEXT since UInt is bigger than Int64 in sqlite
    """
    CREATE TABLE IF NOT EXISTS released (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT NOT NULL
    );
    """
  }

  let rows: [RowRelease]
  let argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  internal init(rows: [RowRelease]) {
    self.rows = rows
    self.argumentBuilder = { $0.insert.parameters }
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }
}
