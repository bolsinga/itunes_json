//
//  DatabaseJournalTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation
import Testing

@testable import iTunes

struct DatabaseJournalTests {
  private func makeDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: "DatabaseJournalTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  // Bytes 18 and 19 of a database file are the file format versions for writing and reading. 1 is
  // a rollback journal and 2 is WAL.
  private func fileFormatVersions(_ data: Data) -> [UInt8] {
    Array(data[18...19])
  }

  private func fill(_ db: Database) async throws {
    try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT);")
    try await db.transaction { db in
      try db.execute("INSERT INTO t (name) VALUES ('one'), ('two'), ('three');")
    }
  }

  // A file database that is still open (the archive command never closes its database) keeps
  // every committed row in the one file.
  @Test func openFileDatabaseKeepsCommittedRowsInTheDatabaseFile() async throws {
    let directory = try makeDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let url = directory.appending(path: "journal.db")
    let db = try Database(context: Database.Context(storage: .file(url), loggingToken: nil))
    try await fill(db)

    let names = try FileManager.default.contentsOfDirectory(atPath: directory.path())
    #expect(names == ["journal.db"], "files: \(names)")

    // Copy only the .db file, then read it back.
    let copy = directory.appending(path: "copy.db")
    try FileManager.default.copyItem(at: url, to: copy)
    let copied = try Database(context: Database.Context(storage: .file(copy), loggingToken: nil))
    let rows = try await copied.execute(query: "SELECT COUNT(*) FROM t;", arguments: [])
    #expect("\(rows[0][0][0].value)" == "3")
    await copied.close()
    await db.close()
  }

  // The bytes from a file database and from a memory database both read as rollback journal files.
  @Test(arguments: [true, false])
  func serializedDatabaseIsNotWAL(_ useFile: Bool) async throws {
    let directory = try makeDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let storage: DatabaseStorage =
      useFile ? .file(directory.appending(path: "journal.db")) : .memory
    let db = try Database(context: Database.Context(storage: storage, loggingToken: nil))
    try await fill(db)
    let data = try await db.data()
    await db.close()

    #expect(fileFormatVersions(data) == [1, 1])
  }

  // Opening a database file that is already in WAL mode puts it back in the rollback journal
  // mode.
  @Test func existingWALFileIsReturnedToTheRollbackJournal() async throws {
    let directory = try makeDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let url = directory.appending(path: "journal.db")
    let db = try Database(context: Database.Context(storage: .file(url), loggingToken: nil))
    try await db.execute("PRAGMA journal_mode = WAL;")
    try await fill(db)
    await db.close()
    #expect(fileFormatVersions(try Data(contentsOf: url)) == [2, 2])

    let reopened = try Database(context: Database.Context(storage: .file(url), loggingToken: nil))
    await reopened.close()
    #expect(fileFormatVersions(try Data(contentsOf: url)) == [1, 1])
  }
}
