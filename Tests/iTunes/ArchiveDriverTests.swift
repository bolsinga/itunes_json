//
//  ArchiveDriverTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation
import Testing

@testable import iTunes

private actor Counter {
  private(set) var running = 0
  private(set) var started = 0
  private(set) var peak = 0

  func start() {
    running += 1
    started += 1
    peak = max(peak, running)
  }

  func stop() { running -= 1 }
}

struct ArchiveDriverTests {
  // Minutes and seconds vary, because dates 1 to 4 whole hours apart read as the same date.
  private static let mar1 = "2026-03-01T10:21:22Z"
  private static let mar9 = "2026-03-09T10:31:32Z"

  private func track(
    id: UInt, artist: String = "Artist", playCount: Int? = nil, playDate: String? = nil,
    sortArtist: String? = nil
  ) -> Track {
    Track(
      album: "Album", artist: artist, dateAdded: "2020-01-01T00:00:00Z", name: "Song",
      persistentID: id, playCount: playCount, playDateUTC: playDate, sortArtist: sortArtist,
      totalTime: 1000, trackCount: 2, trackNumber: 1, year: 2000)
  }

  private func reads(_ snapshots: [(String, [Track])]) -> OrderedReads<[Track]> {
    let byTag = Dictionary(uniqueKeysWithValues: snapshots)
    return OrderedReads(tags: snapshots.map(\.0), window: 2) { byTag[$0] ?? [] }
  }

  private func database() throws -> Database {
    try Database(context: Database.Context(storage: .memory, loggingToken: nil))
  }

  // MARK: OrderedReads

  @Test func valuesAreGivenInTheOrderOfTheTagsEvenIfALaterOneIsReadFirst() async throws {
    let tags = ["a", "b", "c", "d", "e"]
    let reads = OrderedReads<String>(tags: tags, window: 3) { tag in
      if tag == "a" { try await Task.sleep(for: .milliseconds(150)) }
      return tag.uppercased()
    }
    var result = [iTunes.Tag<String>]()
    for try await value in reads { result.append(value) }
    #expect(result.map(\.tag) == tags)
    #expect(result.map(\.item) == ["A", "B", "C", "D", "E"])
  }

  @Test func atMostWindowTagsAreReadAtOnceAndNoneAreReadAheadOfTheConsumer() async throws {
    let counter = Counter()
    let reads = OrderedReads<Int>(tags: (0..<20).map(String.init), window: 3) { _ in
      await counter.start()
      try await Task.sleep(for: .milliseconds(5))
      await counter.stop()
      return 0
    }
    var iterator = reads.makeAsyncIterator()
    _ = try await iterator.next()
    // Only the window was started, and the rest wait for the consumer.
    #expect(await counter.started <= 3)
    while try await iterator.next() != nil {}
    #expect(await counter.started == 20)
    #expect(await counter.peak <= 3)
  }

  @Test func failureEndsTheSequenceAfterTheValuesBeforeIt() async throws {
    struct Boom: Error {}
    let reads = OrderedReads<Int>(tags: ["a", "b", "c", "d"], window: 2) { tag in
      if tag == "c" { throw Boom() }
      return 1
    }
    var seen = [String]()
    do {
      for try await value in reads { seen.append(value.tag) }
      Issue.record("no error")
    } catch ArchiveRunError.cannotRead(let tag, _) {
      #expect(tag == "c")
    }
    #expect(seen == ["a", "b"])
  }

  // MARK: Tag order

  @Test func tagsAreOrderedByTheStructuredTag() {
    #expect(TagOrder.isOrderedBefore("iTunes-V40-2025-05-17", "iTunes-V40-2025-05-18"))
    #expect(!TagOrder.isOrderedBefore("iTunes-V40-2025-05-18", "iTunes-V40-2025-05-17"))
    #expect(!TagOrder.isOrderedBefore("iTunes-V40-2025-05-17", "iTunes-V40-2025-05-17"))
    // The version is before the stamp, as `stampOrderedMatching` sorts.
    #expect(TagOrder.isOrderedBefore("iTunes-V39-2025-06-01", "iTunes-V40-2025-01-01"))
    // Not structured tags are ordered by the string.
    #expect(TagOrder.isOrderedBefore("a", "b"))
  }

  @Test func snapshotTagsAreOneForEachStampAfterTheLastTag() {
    let tags = [
      "iTunes-V39-2025-01-01", "iTunes-V40-2025-01-01", "iTunes-V40-2025-01-02",
      "iTunes-V40-2025-01-03", "iTunes-2025-01-04", "other",
    ]
    #expect(
      tags.stampOrderedMatching(after: nil) == [
        "iTunes-V40-2025-01-01", "iTunes-V40-2025-01-02", "iTunes-V40-2025-01-03",
      ])
    #expect(
      tags.stampOrderedMatching(after: "iTunes-V40-2025-01-01") == [
        "iTunes-V40-2025-01-02", "iTunes-V40-2025-01-03",
      ])
    #expect(tags.stampOrderedMatching(after: "iTunes-V40-2025-01-03").isEmpty)
  }

  // MARK: Driver

  @Test func rebuildAppliesEverySnapshotInOrder() async throws {
    let db = try database()
    let summary = try await db.archiveSnapshots(
      reads([
        (
          "iTunes-V40-2026-01-01",
          [
            track(id: 1, playCount: 40, playDate: Self.mar1, sortArtist: "Artist, The"),
            track(id: 2),
          ]
        ),
        (
          "iTunes-V40-2026-01-02", [track(id: 1, playCount: 43, playDate: Self.mar9), track(id: 2)]
        ),
      ]))
    #expect(summary.applied == 2)
    #expect(summary.lastTag == "iTunes-V40-2026-01-02")
    #expect(summary.findings == ["sortNameFilled": 1])
    #expect(
      try await db.execute(query: "SELECT delta, count, tag FROM plays ORDER BY id", arguments: [])
        .first?.map { $0.map(\.value.description) } == [
          ["40", "40", "iTunes-V40-2026-01-01"], ["3", "43", "iTunes-V40-2026-01-02"],
        ])
    #expect(summary.text.contains("Applied 2 snapshot(s)."))
    #expect(summary.text.contains("sortNameFilled: 1"))
  }

  @Test func updateAppliesOnlyTheNewSnapshots() async throws {
    let db = try database()
    let first = ("iTunes-V40-2026-01-01", [track(id: 1, playCount: 40, playDate: Self.mar1)])
    let second = ("iTunes-V40-2026-01-02", [track(id: 1, playCount: 43, playDate: Self.mar9)])
    _ = try await db.archiveSnapshots(reads([first]))
    let summary = try await db.archiveSnapshots(reads([second]))
    #expect(summary.applied == 1)
    #expect(summary.lastTag == second.0)

    // The same as one run.
    let once = try database()
    _ = try await once.archiveSnapshots(reads([first, second]))
    let query = "SELECT itunesid, date, delta, count, tag FROM plays ORDER BY id"
    let updated = try await db.execute(query: query, arguments: []).first?.map {
      $0.map(\.value.description)
    }
    let rebuilt = try await once.execute(query: query, arguments: []).first?.map {
      $0.map(\.value.description)
    }
    #expect(updated == rebuilt)
    #expect(updated?.count == 2)
  }

  @Test func nothingNewAppliesNothing() async throws {
    let db = try database()
    let summary = try await db.archiveSnapshots(reads([]))
    #expect(summary == ArchiveRunSummary(applied: 0, lastTag: nil, findings: [:]))
    #expect(summary.text.contains("No findings."))
  }

  @Test func snapshotThatIsNotNewerStopsTheRunAndKeepsTheOnesBefore() async throws {
    let db = try database()
    _ = try await db.archiveSnapshots(reads([("iTunes-V40-2026-01-02", [track(id: 1)])]))
    await #expect(throws: ArchiveRunError.self) {
      _ = try await db.archiveSnapshots(
        reads([
          ("iTunes-V40-2026-01-03", [track(id: 2)]), ("iTunes-V40-2026-01-01", [track(id: 3)]),
        ]))
    }
    #expect(try await db.archiveLastTag() == "iTunes-V40-2026-01-03")
    #expect(
      try await db.execute(query: "SELECT itunesid FROM songs ORDER BY itunesid", arguments: [])
        .first?.map { $0.map(\.value.description) } == [["1"], ["2"]])
  }
}
