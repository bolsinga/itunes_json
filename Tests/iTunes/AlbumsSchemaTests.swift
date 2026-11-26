//
//  AlbumsSchemaTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Testing

@testable import iTunes

struct AlbumsSchemaTests {
  // Strict and lax albums.
  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func albumsArtistIDIsNotNull(_ schemaOptions: SchemaOptions) async throws {
    let db = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
    ).database(tracks: [])

    let columns = try await db.execute(query: "PRAGMA table_info(albums);", arguments: [])
    let artistID = try #require(
      columns[0].first { row in
        row.contains {
          if case .string(let name) = $0.value { return $0.column == "name" && name == "artistid" }
          return false
        }
      })
    let notNull = try #require(artistID.first { $0.column == "notnull" })
    guard case .integer(let flag) = notNull.value else {
      Issue.record("notnull is not an integer")
      return
    }
    #expect(flag == 1)
  }

  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func albumWithoutAnArtistIsRejected(_ schemaOptions: SchemaOptions) async throws {
    let db = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
    ).database(tracks: [])

    await #expect(throws: (any Error).self) {
      try await db.execute(
        "INSERT INTO albums (artistid, name, trackcount, disccount, discnumber, compilation) VALUES (NULL, 'A', 1, 1, 1, 0);"
      )
    }
  }
}
