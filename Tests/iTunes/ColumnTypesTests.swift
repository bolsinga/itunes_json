//
//  ColumnTypesTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import SQLite3
import Testing

@testable import iTunes

// The normalized and flat tables are SQLite STRICT tables (see RFC 0004, "Column types"). These
// tests pin the facts that rests on: STRICT is available, every column is INTEGER or TEXT, and the
// code never stores a value of a different kind than its column declares.
struct ColumnTypesTests {
  private let allColumns = """
    SELECT m.name, p.name, p.type FROM sqlite_master m, pragma_table_info(m.name) p
    WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%' ORDER BY m.name, p.cid;
    """

  // A complete track with a play, and incomplete ones: missing numbers, dates and album.
  private var tracks: [Track] {
    [
      Track(
        album: "Album", artist: "Artist", comments: "Comments", compilation: true,
        composer: "Composer", dateAdded: "2003-12-15T17:02:56Z", discCount: 2, discNumber: 1,
        name: "Complete", persistentID: UInt.max, playCount: 3,
        playDateUTC: "2004-01-01T00:00:00Z", releaseDate: "1999-01-01T00:00:00Z", totalTime: 1000,
        trackCount: 4, trackNumber: 2, year: 1999),
      Track(artist: "Artist", name: "Incomplete", persistentID: 2),
      Track(album: "Album", artist: "Artist", name: "No Play", persistentID: 3),
    ]
  }

  // The declared type of every column, and the columns that hold a value of some other kind.
  private func mismatches(in db: Database) async throws -> (types: [String], bad: [String]) {
    let rows = try await db.execute(query: allColumns, arguments: []).flatMap { $0 }
    var types = [String]()
    var bad = [String]()
    for row in rows {
      let table = try #require(row[0].value.string)
      let column = try #require(row[1].value.string)
      let type = try #require(row[2].value.string)
      types.append(type)
      let found = try await db.execute(
        query: """
          SELECT COUNT(*) FROM "\(table)"
          WHERE typeof("\(column)") NOT IN ('\(type.lowercased())', 'null');
          """, arguments: [])
      if let count = found[0][0][0].value.integer, count != 0 {
        bad.append("\(table).\(column) (\(type)): \(count)")
      }
    }
    return (types, bad)
  }

  private func check(_ db: Database, strict: Bool = true) async throws {
    let tables = try await db.execute(
      query:
        "SELECT name, strict FROM pragma_table_list WHERE schema = 'main' AND type = 'table' AND name NOT LIKE 'sqlite_%';",
      arguments: [])
    #expect(!tables[0].isEmpty)
    for row in tables[0] where strict {
      #expect(row[1].value.integer == 1, "\(row[0].value) is not STRICT")
    }
    let (types, bad) = try await mismatches(in: db)
    #expect(!types.isEmpty)
    #expect(Set(types).isSubset(of: ["INTEGER", "TEXT"]), "\(Set(types))")
    #expect(bad.isEmpty, "\(bad)")
  }

  @Test func sqliteSupportsStrictTables() {
    #expect(sqlite3_libversion_number() >= 3_037_000, "\(String(cString: sqlite3_libversion()))")
  }

  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func normalizedColumns(_ schemaOptions: SchemaOptions) async throws {
    // The strict schema cannot load the incomplete tracks, so it gets only the complete one.
    let tracks = schemaOptions.isEmpty ? Array(tracks.prefix(1)) : tracks
    try await check(
      try await DatabaseFormat.normalized(
        DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
      ).database(tracks: tracks))
  }

  // The SQL code writes values as literals instead of bound parameters.
  @Test func sqlCodeColumns() async throws {
    let data = try tracks.sqlData(
      SQLCodeContext(output: .standardOut, schemaOptions: .laxSchema, loggingToken: nil))
    let db = try Database(context: Database.Context(storage: .memory, loggingToken: nil))
    try await db.execute(String(decoding: data, as: UTF8.self))
    try await check(db)
  }

  @Test func flatColumns() async throws {
    try await check(
      try await DatabaseFormat.flat(FlatTracksDatabaseContext(storage: .memory))
        .database(tracks: tracks))
  }

  // An encoder prepares one INSERT, so each kind of correction gets its own database.
  @Test(arguments: CorrectionsDBTests.repairs)
  func correctionsColumns(_ repair: IdentityRepair) async throws {
    let encoder = try FlatDBEncoder(context: CorrectionsDBContext(storage: .memory))
    try await encoder.encode(items: [repair])
    // A patch file is edited by hand, so its tables are not STRICT.
    try await check(encoder.db, strict: false)
  }

  // A STRICT table is stricter about the kind of value than an ordinary one, which stores any
  // text in an INTEGER column.
  @Test func strictTableRejectsTextInAnIntegerColumn() async throws {
    let db = try Database(context: Database.Context(storage: .memory, loggingToken: nil))
    try await db.execute("CREATE TABLE plain (n INTEGER); CREATE TABLE firm (n INTEGER) STRICT;")
    try await db.execute("INSERT INTO plain (n) VALUES ('seven'), ('7');")
    let kinds = try await db.execute(
      query: "SELECT typeof(n) FROM plain ORDER BY rowid;", arguments: [])
    #expect(kinds[0].map { $0[0].value.string } == ["text", "integer"])
    await #expect(throws: (any Error).self) {
      try await db.execute("INSERT INTO firm (n) VALUES ('seven');")
    }
  }
}
