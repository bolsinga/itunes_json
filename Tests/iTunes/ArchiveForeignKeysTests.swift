//
//  ArchiveForeignKeysTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveForeignKeysTests {
  private func value(_ db: Database, _ query: String) async throws -> String {
    let rows = try await db.execute(query: query, arguments: [])
    return "\(rows[0][0][0].value)"
  }

  private let track = Track(
    album: "Album", artist: "Artist", name: "Song", persistentID: 1, totalTime: 1000, trackCount: 1,
    trackNumber: 1, year: 2000)

  // The archive turns the setting on for the connection it writes with, and the result is
  // consistent.
  @Test func archiveEnforcesForeignKeys() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let archive = try await DatabaseFormat.normalized(
      DatabaseContext(
        storage: .file(directory.appending(path: "archive.db")), schemaOptions: SchemaOptions(),
        loggingToken: nil)
    ).database(tracks: [])
    let snapshot = try await DatabaseFormat.flat(FlatTracksDatabaseContext(storage: .memory))
      .database(tracks: [track])
    #expect(try await value(snapshot, "PRAGMA foreign_keys;") == "0")

    try await snapshot.archive(into: archive.filename)

    #expect(try await value(snapshot, "PRAGMA foreign_keys;") == "1")
    #expect(try await value(archive, "SELECT COUNT(*) FROM songs;") == "1")
    try await archive.requireNoForeignKeyViolations()
  }

  @Test func orphanRowIsReported() async throws {
    let db = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: SchemaOptions(), loggingToken: nil)
    ).database(tracks: [track])
    try await db.requireNoForeignKeyViolations()

    // The database that was built keeps the setting on, which would reject the orphan.
    try await db.execute("PRAGMA foreign_keys = OFF;")
    try await db.execute(
      "INSERT INTO songs (itunesid, name, artistid, albumid, tracknumber, year, duration) VALUES ('9', 'Orphan', -1, -1, 1, 2000, 1000);"
    )
    let error = try await #require(throws: DatabaseError.self) {
      try await db.requireNoForeignKeyViolations()
    }
    guard case .foreignKeyViolations(let count) = error else {
      Issue.record("\(error)")
      return
    }
    // One for the missing artist and one for the missing album.
    #expect(count == 2)
  }
}
