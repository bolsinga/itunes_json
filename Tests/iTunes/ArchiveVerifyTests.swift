//
//  ArchiveVerifyTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveVerifyTests {
  // Minutes and seconds vary, because dates 1 to 4 whole hours apart read as the same date.
  private static let mar1 = "2026-03-01T10:21:22Z"
  private static let mar9 = "2026-03-09T10:31:32Z"

  private static func track(
    id: UInt, playCount: Int? = nil, playDate: String? = nil, year: Int = 2000
  )
    -> Track
  {
    Track(
      album: "Album", artist: "Artist", dateAdded: "2020-01-01T00:00:00Z", name: "Song",
      persistentID: id, playCount: playCount, playDateUTC: playDate, totalTime: 1000,
      trackCount: 2, trackNumber: 1, year: year)
  }

  private static let first = (
    "iTunes-V40-2026-01-01",
    [
      Self.track(id: 1, playCount: 40, playDate: Self.mar1),
      Self.track(id: 2, playCount: 3, playDate: Self.mar1, year: 0),
    ]
  )
  private static let second = (
    "iTunes-V40-2026-01-02",
    [
      Self.track(id: 1, playCount: 43, playDate: Self.mar9),
      Self.track(id: 2, playCount: 4, playDate: Self.mar9, year: 0),
    ]
  )
  private static let third = (
    "iTunes-V40-2026-01-03",
    [
      Self.track(id: 1, playCount: 43, playDate: Self.mar9),
      Self.track(id: 2, playCount: 5, playDate: "2026-03-12T07:33:52Z"),
    ]
  )

  private func reads(_ snapshots: [(String, [Track])]) -> OrderedReads<[Track]> {
    let byTag = Dictionary(uniqueKeysWithValues: snapshots)
    return OrderedReads(tags: snapshots.map(\.0), window: 2) { byTag[$0] ?? [] }
  }

  private func fileDatabase(_ directory: URL, _ name: String) throws -> Database {
    try Database(
      context: Database.Context(
        storage: .file(directory.appending(path: name)), loggingToken: nil))
  }

  private func withDirectory(_ body: (URL) async throws -> Void) async throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    try await body(directory)
  }

  @Test func updatedArchiveIsEqualToItsRebuild() async throws {
    let (first, second, third) = (Self.first, Self.second, Self.third)
    try await withDirectory { directory in
      // Updated one snapshot at a time, and rebuilt in one run.
      let updated = try fileDatabase(directory, "updated.db")
      _ = try await updated.archiveSnapshots(reads([first]))
      _ = try await updated.archiveSnapshots(reads([second]))
      _ = try await updated.archiveSnapshots(reads([third]))
      let rebuilt = try fileDatabase(directory, "rebuilt.db")
      _ = try await rebuilt.archiveSnapshots(reads([first, second, third]))
      #expect(
        try await updated.archiveDifferences(
          rebuiltAt: directory.appending(path: "rebuilt.db").path) == [])
      // The track that was invalid and was fixed has its whole history.
      #expect(
        try await updated.execute(
          query: "SELECT delta, count, tag FROM plays WHERE itunesid = '2' ORDER BY id",
          arguments: []
        ).first?.map { $0.map(\.value.description) } == [
          ["3", "3", first.0], ["1", "4", second.0], ["1", "5", third.0],
        ])
      await updated.close()
      await rebuilt.close()
    }
  }

  @Test func theToolVersionIsNotCompared() async throws {
    let first = Self.first
    try await withDirectory { directory in
      let one = try fileDatabase(directory, "one.db")
      _ = try await one.archiveSnapshots(reads([first]))
      let other = try fileDatabase(directory, "other.db")
      _ = try await other.archiveSnapshots(reads([first]))
      try await other.execute("UPDATE archivestate SET value = 'old' WHERE key = 'toolversion'")
      #expect(
        try await one.archiveDifferences(rebuiltAt: directory.appending(path: "other.db").path)
          == [])
      await one.close()
      await other.close()
    }
  }

  @Test func differencesAreFoundInEitherDirection() async throws {
    let (first, second) = (Self.first, Self.second)
    try await withDirectory { directory in
      let archive = try fileDatabase(directory, "archive.db")
      _ = try await archive.archiveSnapshots(reads([first, second]))
      let rebuilt = try fileDatabase(directory, "rebuilt.db")
      _ = try await rebuilt.archiveSnapshots(reads([first, second]))
      // A row that is different, and a row that only the archive has.
      try await rebuilt.execute("UPDATE songs SET name = 'Other' WHERE itunesid = '1'")
      try await archive.execute(
        "INSERT INTO findings (tag, itunesid, code, detail) VALUES ('t', NULL, 'extra', 'd')")
      let differences = try await archive.archiveDifferences(
        rebuiltAt: directory.appending(path: "rebuilt.db").path)
      #expect(differences.map(\.table) == ["songs", "findings"])
      #expect(differences[0].onlyInArchive == 1)
      #expect(differences[0].onlyInRebuild == 1)
      #expect(differences[0].examples.contains { $0.hasPrefix("rebuild: 1 | Other") })
      #expect(differences[1].onlyInArchive == 1)
      #expect(differences[1].onlyInRebuild == 0)
      #expect(ArchiveVerifyError(differences: differences).description.contains("songs: 1 row(s)"))
      await archive.close()
      await rebuilt.close()
    }
  }

  @Test func tagsAreLimitedToThoseThroughTheLastOne() {
    let tags = [
      "iTunes-V40-2025-01-01", "iTunes-V40-2025-01-02", "iTunes-V40-2025-01-03",
      "iTunes-V40-2025-01-04",
    ]
    #expect(
      tags.stampOrderedMatching(after: nil, through: "iTunes-V40-2025-01-03") == [
        "iTunes-V40-2025-01-01", "iTunes-V40-2025-01-02", "iTunes-V40-2025-01-03",
      ])
    #expect(
      tags.stampOrderedMatching(after: "iTunes-V40-2025-01-01", through: "iTunes-V40-2025-01-03")
        == ["iTunes-V40-2025-01-02", "iTunes-V40-2025-01-03"])
    #expect(tags.stampOrderedMatching(after: nil, through: nil) == tags)
  }
}
