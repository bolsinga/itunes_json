//
//  ForeignKeyTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation
import Testing

@testable import iTunes

struct ForeignKeyTests {
  private var tracks: [Track] {
    [
      Track(
        album: "Album", artist: "Artist", discCount: 1, discNumber: 1, name: "One",
        persistentID: 1, playCount: 2, playDateUTC: "2003-12-15T17:02:56Z",
        totalTime: 1000, trackCount: 2, trackNumber: 1, year: 2000),
      Track(
        album: "Album", artist: "Artist", discCount: 1, discNumber: 1, name: "Two",
        persistentID: 2, totalTime: 1000, trackCount: 2, trackNumber: 2, year: 2000),
    ]
  }

  private func scalar(_ db: Database, _ sql: String) async throws -> String {
    let result = try await db.execute(query: sql, arguments: [])
    return "\(result[0][0][0].value)"
  }

  // Every id the `--db` path looks up is found, so the `-1` fallback is never stored.
  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func databaseHasNoForeignKeyViolations(_ schemaOptions: SchemaOptions) async throws {
    let db = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
    ).database(tracks: tracks)

    #expect(try await scalar(db, "SELECT COUNT(*) FROM pragma_foreign_key_check;") == "0")
    #expect(
      try await scalar(db, "SELECT COUNT(*) FROM songs WHERE artistid = -1 OR albumid = -1;")
        == "0")
    #expect(try await scalar(db, "SELECT COUNT(*) FROM songs;") == "2")
  }

  // The keys are declared in the file, but the setting that enforces them belongs to a connection.
  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func fileDoesNotKeepEnforcement(_ schemaOptions: SchemaOptions) async throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let file = directory.appending(path: "keys.db")

    let writer = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .file(file), schemaOptions: schemaOptions, loggingToken: nil)
    ).database(tracks: tracks)
    #expect(try await scalar(writer, "PRAGMA foreign_keys;") == "1")
    await writer.close()

    let reader = try Database(context: Database.Context(storage: .file(file), loggingToken: nil))
    #expect(try await scalar(reader, "PRAGMA foreign_keys;") == "0")
    #expect(
      try await scalar(reader, "SELECT COUNT(*) FROM pragma_foreign_key_list('songs');") == "2")
    // With the setting off, a song that names a missing artist and album is accepted.
    try await reader.execute(
      "INSERT INTO songs (itunesid, name, artistid, albumid, tracknumber, year, duration) VALUES ('9', 'Orphan', -1, -1, 1, 2000, 1000);"
    )
    // The check reports one row for each key that is not met: the artist and the album.
    #expect(try await scalar(reader, "SELECT COUNT(*) FROM pragma_foreign_key_check;") == "2")
    await reader.close()
  }
}
