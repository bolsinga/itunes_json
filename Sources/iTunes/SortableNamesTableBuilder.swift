//
//  SortableNameTableBuilder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/16/24.
//

import Foundation

struct SortableNamesTableBuilder: TableBuilder {
  let rows: [SortableName]
  let tableName: String

  internal init(rows: [SortableName], tableName: String) {
    self.rows = rows.sorted()
    self.tableName = tableName
  }

  func schema(constraints: SchemaConstraints = .strict) -> String {
    """
    CREATE TABLE \(tableName) (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      sortname TEXT NOT NULL DEFAULT '',
      CHECK(length(name) > 0),
      CHECK(name != sortname)
    );
    CREATE VIEW current AS
      SELECT * FROM \(tableName)
    ;
    CREATE TRIGGER forward_insert
      INSTEAD OF INSERT ON current
    BEGIN
      INSERT INTO \(tableName) (id, name, sortname) SELECT new.id, new.name, new.sortname;
    END;
    """
  }

  var statements: [Database.Statement] { rows.map { $0.insert } }

  var argumentBuilder: (@Sendable (Row) -> [Database.Value])? { { $0.insert.parameters } }

  var dropStatements: [String] {
    [
      "DROP VIEW IF EXISTS current;",
      "DROP TRIGGER IF EXISTS forward_insert;",
    ]
  }

  func encode() -> String {
    var source = [schema()]
    source.append(contentsOf: statements.map { "\($0)" })
    source.append(contentsOf: dropStatements)
    return source.joined(separator: "\n")
  }
}
