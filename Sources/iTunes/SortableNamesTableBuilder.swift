//
//  SortableNameTableBuilder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/16/24.
//

import Foundation

struct SortableNamesTableBuilder: TableBuilder {
  let rows: [SortableName]

  internal init(rows: [SortableName]) {
    self.rows = rows.sorted()
  }

  func schema(constraints: SchemaConstraints = .strict) -> String {
    """
    CREATE TABLE artists (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      sortname TEXT NOT NULL DEFAULT '',
      CHECK(length(name) > 0),
      CHECK(name != sortname)
    )
    """
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? { { $0.insert.parameters } }

  func encode() -> String {
    var source = [schema()]
    source.append(contentsOf: statements.map { "\($0)" })
    return source.joined(separator: "\n")
  }
}
