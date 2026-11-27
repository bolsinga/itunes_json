//
//  StrictTablesTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Testing

@testable import iTunes

struct StrictTablesTests {
  private func expectEveryTableIsStrict(_ db: Database) async throws {
    let tables = try await db.execute(
      query: "SELECT name, strict FROM pragma_table_list WHERE schema = 'main' AND type = 'table';",
      arguments: [])
    #expect(!tables[0].isEmpty)
    for row in tables[0] where !row[0].value.string!.hasPrefix("sqlite_") {
      #expect(row[1].value.integer == 1, "\(row[0].value) is not STRICT")
    }
  }

  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func normalizedTables(_ schemaOptions: SchemaOptions) async throws {
    try await expectEveryTableIsStrict(
      try await DatabaseFormat.normalized(
        DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
      ).database(tracks: []))
  }

  @Test func flatTable() async throws {
    try await expectEveryTableIsStrict(
      try await DatabaseFormat.flat(FlatTracksDatabaseContext(storage: .memory))
        .database(tracks: [
          Track(
            album: "Album", artist: "Artist", name: "Song", persistentID: 1, totalTime: 1000,
            trackCount: 1, trackNumber: 1, year: 2000)
        ]))
  }
}
