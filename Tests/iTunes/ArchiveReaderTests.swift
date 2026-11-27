//
//  ArchiveReaderTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveReaderTests {
  // Minutes and seconds vary, because dates 1 to 4 whole hours apart read as the same date.
  private static let feb3 = "2026-02-03T10:11:12Z"
  private static let mar1 = "2026-03-01T10:21:22Z"
  private static let mar9 = "2026-03-09T10:31:32Z"
  private static let mar20 = "2026-03-20T10:41:42Z"

  private func track(
    id: UInt, name: String = "Song", album: String? = "Album", artist: String? = "Artist",
    compilation: Bool? = nil, dateAdded: String? = "2020-01-01T00:00:00Z", playCount: Int? = nil,
    playDate: String? = nil, podcast: Bool? = nil, releaseDate: String? = nil,
    sortArtist: String? = nil, trackCount: Int? = 2, year: Int? = 2000
  ) -> Track {
    Track(
      album: album, artist: artist, compilation: compilation, dateAdded: dateAdded, name: name,
      persistentID: id, playCount: playCount, playDateUTC: playDate, podcast: podcast,
      releaseDate: releaseDate, sortArtist: sortArtist, totalTime: 1000, trackCount: trackCount,
      trackNumber: 1, year: year)
  }

  /// Snapshots that use every rule that keeps something for the next one.
  private var snapshots: [(String, [Track])] {
    [
      (
        "t1",
        [
          // Some tracks of an artist have a sort name and some do not.
          track(id: 1, artist: "A", playCount: 40, playDate: Self.mar1, sortArtist: "A, The"),
          track(id: 2, artist: "A"),
          // A year of 0 in every snapshot until t3.
          track(id: 3, artist: "B", year: 0),
          // A compilation with no Album Artist.
          track(id: 4, name: "Comp", album: "Hits", artist: "C", compilation: true),
          // One ID twice.
          track(id: 5, name: "Dup", artist: "D", dateAdded: "2019-01-01T00:00:00Z"),
          track(id: 5, name: "Dup copy", artist: "D", dateAdded: "2021-01-01T00:00:00Z"),
          track(id: 6, artist: "E", podcast: true),
          // Valid now, and invalid later.
          track(id: 7, artist: "F", year: 1999),
          track(id: 8, artist: "G", playCount: 4, playDate: nil),
          // Not in later snapshots.
          track(id: 9, artist: "H"),
        ]
      ),
      (
        "t2",
        [
          track(id: 1, artist: "A", playCount: 43, playDate: Self.mar9, sortArtist: "A, The"),
          track(id: 2, artist: "A"),
          track(id: 3, artist: "B", year: 0),
          track(id: 4, name: "Comp", album: "Hits", artist: "C", compilation: true),
          track(id: 7, artist: "F", year: 0),
          track(id: 8, artist: "G", playCount: 4, playDate: Self.feb3),
          track(id: 9, artist: "H", playCount: 1, playDate: Self.feb3),
        ]
      ),
      (
        "t3",
        [
          track(id: 1, artist: "A", playCount: 43, playDate: Self.mar9, sortArtist: "A, The"),
          track(id: 2, artist: "A", sortArtist: "A, The"),
          track(id: 3, artist: "B", playCount: 7, playDate: Self.mar1, year: 2001),
          track(id: 4, name: "Comp", album: "Hits", artist: "C", compilation: true),
          track(id: 7, artist: "F", year: 0),
        ]
      ),
      (
        "t4",
        [
          // A reset, and a date added that changed.
          track(id: 1, artist: "A", playCount: 2, playDate: Self.mar20, sortArtist: "A, The"),
          // The sort name is gone again.
          track(id: 2, artist: "A", trackCount: 3),
          track(id: 3, artist: "B", playCount: 7, playDate: Self.mar1, year: 2001),
          track(
            id: 4, name: "Comp", album: "Hits", artist: "C", compilation: true,
            dateAdded: "2022-02-02T02:22:22Z"),
          track(id: 7, artist: "F", year: 0),
        ]
      ),
    ]
  }

  private func database() async throws -> Database {
    let db = try Database(context: Database.Context(storage: .memory, loggingToken: nil))
    try await db.prepareArchive()
    return db
  }

  private func dump(_ db: Database) async throws -> [String: [[String]]] {
    var tables = [String: [[String]]]()
    for table in [
      "artists", "albums", "songs", "added", "released", "plays", "playstate", "findings",
      "archivestate",
    ] {
      tables[table] =
        try await db.execute(query: "SELECT * FROM \(table) ORDER BY rowid", arguments: []).first?
        .map { $0.map(\.value.description) } ?? []
    }
    return tables
  }

  @Test func emptyArchiveLoadsAnEmptyState() async throws {
    let db = try await database()
    #expect(try await db.loadArchiveState() == ArchiveState())
  }

  @Test func loadedStateIsTheStateAfterEachSnapshot() async throws {
    let db = try await database()
    var state = ArchiveState()
    for (tag, tracks) in snapshots {
      try await db.writeArchive(state.apply(iTunes.Tag(tag: tag, item: tracks)))
      #expect(try await db.loadArchiveState() == state, "\(tag)")
    }
  }

  @Test func updatingEachSnapshotGivesTheSameDatabaseAsOneRun() async throws {
    // A rebuild keeps its state in memory.
    let rebuilt = try await database()
    var state = ArchiveState()
    for (tag, tracks) in snapshots {
      try await rebuilt.writeArchive(state.apply(iTunes.Tag(tag: tag, item: tracks)))
    }

    // An update reads the state from the database each time.
    let updated = try await database()
    for (tag, tracks) in snapshots {
      var loaded = try await updated.loadArchiveState()
      try await updated.writeArchive(loaded.apply(iTunes.Tag(tag: tag, item: tracks)))
    }

    let expected = try await dump(rebuilt)
    let actual = try await dump(updated)
    for table in expected.keys.sorted() {
      #expect(actual[table] == expected[table], "\(table)")
    }
    // The scenario has what the carried state is for.
    let findings = (expected["findings"] ?? []).map { $0[3] }
    for code in [
      "sortNameFilled", "invalidTrack", "duplicatePersistentID", "compilationNoAlbumArtist",
      "countReset", "dateAddedChanged", "noPlayDate",
    ] {
      #expect(findings.contains(code), "\(code)")
    }
  }

  @Test func findingThatIsNotAboutASongIsNotRepeatedByAnUpdate() async throws {
    let db = try await database()
    for (tag, tracks) in snapshots.prefix(2) {
      var state = try await db.loadArchiveState()
      try await db.writeArchive(state.apply(iTunes.Tag(tag: tag, item: tracks)))
    }
    // The artist has no sort name on one track in both snapshots, which is one finding.
    let count = try await db.execute(
      query: "SELECT COUNT(*) FROM findings WHERE code = 'sortNameFilled'", arguments: []
    ).first?.first?.first?.value.description
    #expect(count == "1")
  }

  @Test func requiredNumbersOfASongWithNoRowAreKept() async throws {
    let db = try await database()
    var state = ArchiveState()
    // The year is valid and the track count is not, in two different snapshots.
    try await db.writeArchive(
      state.apply(
        iTunes.Tag(tag: "t1", item: [track(id: 1, trackCount: nil, year: 1999)])))
    var loaded = try await db.loadArchiveState()
    #expect(loaded.attributes[1]?.year == 1999)
    #expect(loaded.lastSeen[1] == nil)
    let changes = loaded.apply(
      iTunes.Tag(tag: "t2", item: [track(id: 1, trackCount: 9, year: 0)]))
    #expect(changes.songs.first?.year == 1999)
    #expect(changes.songs.first?.trackCount == 9)
  }
}
