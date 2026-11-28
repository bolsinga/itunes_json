//
//  ArchiveWriterTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveWriterTests {
  // Minutes and seconds vary, because dates 1 to 4 whole hours apart read as the same date.
  private static let feb3 = "2026-02-03T10:11:12Z"
  private static let mar1 = "2026-03-01T10:21:22Z"
  private static let mar9 = "2026-03-09T10:31:32Z"

  private func track(
    id: UInt, name: String = "Song", album: String? = "Album", albumArtist: String? = nil,
    artist: String? = "Artist", compilation: Bool? = nil,
    dateAdded: String? = "2020-01-01T00:00:00Z",
    playCount: Int? = nil, playDate: String? = nil, releaseDate: String? = nil,
    sortAlbum: String? = nil, sortArtist: String? = nil, trackCount: Int? = 2
  ) -> Track {
    Track(
      album: album, albumArtist: albumArtist, artist: artist, compilation: compilation,
      dateAdded: dateAdded, name: name, persistentID: id, playCount: playCount,
      playDateUTC: playDate, releaseDate: releaseDate, sortAlbum: sortAlbum, sortArtist: sortArtist,
      totalTime: 1000, trackCount: trackCount, trackNumber: 1, year: 2000)
  }

  private func snapshot(_ tag: String, _ tracks: [Track]) -> iTunes.Tag<[Track]> {
    iTunes.Tag(tag: tag, item: tracks)
  }

  private func database() async throws -> Database {
    let db = try Database(context: Database.Context(storage: .memory, loggingToken: nil))
    try await db.prepareArchive()
    return db
  }

  private func query(_ db: Database, _ sql: String) async throws -> [[String]] {
    try await db.execute(query: sql, arguments: []).first?.map { $0.map(\.value.description) }
      ?? []
  }

  private func write(
    _ db: Database, _ state: inout ArchiveState, _ tag: String, _ tracks: [Track]
  ) async throws {
    try await db.writeArchive(state.apply(snapshot(tag, tracks)))
  }

  // MARK: Schema

  @Test func schemaIsCreatedOnceAndHasTheTablesAndViews() async throws {
    let db = try await database()
    try await db.prepareArchive()
    let names = try await query(
      db, "SELECT name FROM sqlite_master WHERE type IN ('table', 'view') ORDER BY name")
    for name in [
      "added", "albums", "archivestate", "artists", "findings", "lastplays", "playstate", "plays",
      "released", "removedsongs", "sharedplaydates", "songs", "tracks",
    ] {
      #expect(names.contains([name]), "\(name)")
    }
    #expect(!names.contains(["artistids"]))
    #expect(!names.contains(["albumids"]))
    #expect(
      try await query(db, "SELECT value FROM archivestate WHERE key = 'schemaversion'")
        == [[ArchiveSchema.version]])
    #expect(try await db.archiveLastTag() == nil)
  }

  @Test func playsRejectBadRows() async throws {
    let db = try await database()
    try await db.execute(
      "INSERT INTO artists (name) VALUES ('A'); INSERT INTO albums (artistid, name, trackcount, disccount, discnumber, compilation) VALUES (1, 'B', 1, 1, 1, 0); INSERT INTO songs (itunesid, name, artistid, albumid, tracknumber, year, duration, lastseen) VALUES ('1', 'S', 1, 1, 1, 2000, 10, 't');"
    )
    try await db.execute(
      "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES ('1', 'd', 2, 2, 't')")
    // The same song and date.
    await #expect(throws: DatabaseError.self) {
      try await db.execute(
        "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES ('1', 'd', 1, 3, 't')")
    }
    // A delta of 0, and a total that is less than the delta.
    await #expect(throws: DatabaseError.self) {
      try await db.execute(
        "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES ('1', 'e', 0, 3, 't')")
    }
    await #expect(throws: DatabaseError.self) {
      try await db.execute(
        "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES ('1', 'f', 3, 2, 't')")
    }
    // A song that is not there.
    await #expect(throws: DatabaseError.self) {
      try await db.execute(
        "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES ('9', 'g', 1, 1, 't')")
    }
  }

  // MARK: Writer

  @Test func firstSnapshotIsWritten() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(
      db, &state, "t1",
      [
        track(
          id: 1, name: "One", playCount: 12, playDate: Self.feb3,
          releaseDate: "2019-05-05T05:05:05Z",
          sortArtist: "Artist, The"),
        track(id: 2, name: "Two"),
      ])
    #expect(
      try await query(db, "SELECT name, sortname FROM artists") == [["Artist", "Artist, The"]])
    #expect(
      try await query(db, "SELECT name, trackcount, disccount, discnumber, compilation FROM albums")
        == [["Album", "2", "1", "1", "0"]])
    #expect(
      try await query(db, "SELECT itunesid, name, lastseen FROM songs ORDER BY itunesid")
        == [["1", "One", "t1"], ["2", "Two", "t1"]])
    #expect(
      try await query(db, "SELECT itunesid, date, delta, count, tag FROM plays")
        == [["1", Self.feb3, "12", "12", "t1"]])
    #expect(
      try await query(db, "SELECT itunesid, seencount, seendate FROM playstate")
        == [["1", "12", Self.feb3]])
    #expect(
      try await query(db, "SELECT itunesid, date FROM added ORDER BY itunesid")
        == [["1", "2020-01-01T00:00:00Z"], ["2", "2020-01-01T00:00:00Z"]])
    #expect(
      try await query(db, "SELECT itunesid, date FROM released") == [["1", "2019-05-05T05:05:05Z"]])
    #expect(try await db.archiveLastTag() == "t1")
    #expect(try await query(db, "PRAGMA foreign_key_check").isEmpty)
  }

  @Test func laterSnapshotsAddPlaysAndFindings() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(db, &state, "t1", [track(id: 1, playCount: 40, playDate: Self.mar1)])
    try await write(db, &state, "t2", [track(id: 1, playCount: 43, playDate: Self.mar9)])
    // A reset, then plays.
    try await write(
      db, &state, "t3", [track(id: 1, playCount: 2, playDate: "2026-03-20T10:41:42Z")])
    #expect(
      try await query(db, "SELECT delta, count, tag FROM plays ORDER BY id")
        == [["40", "40", "t1"], ["3", "43", "t2"], ["2", "45", "t3"]])
    #expect(
      try await query(db, "SELECT tag, itunesid, code FROM findings") == [
        ["t3", "1", "countReset"]
      ])
    // The total is the running sum of the deltas.
    #expect(
      try await query(
        db,
        "SELECT COUNT(*) FROM plays p WHERE p.count != (SELECT SUM(delta) FROM plays q WHERE q.itunesid = p.itunesid AND q.id <= p.id)"
      ) == [["0"]])
    #expect(try await query(db, "SELECT count FROM lastplays") == [["45"]])
  }

  @Test func songThatLeavesStaysAndIsListedAsRemoved() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(
      db, &state, "t1", [track(id: 1, playCount: 5, playDate: Self.mar1), track(id: 2)])
    try await write(db, &state, "t2", [track(id: 2)])
    #expect(
      try await query(db, "SELECT itunesid, lastseen FROM songs ORDER BY itunesid")
        == [["1", "t1"], ["2", "t2"]])
    #expect(try await query(db, "SELECT itunesid FROM removedsongs") == [["1"]])
    #expect(try await query(db, "SELECT count FROM plays") == [["5"]])
  }

  @Test func compilationBecomesOneAlbumOwnedByVariousArtists() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(
      db, &state, "t1",
      [
        track(id: 1, name: "A", album: "Hits", artist: "First", compilation: true),
        track(id: 2, name: "B", album: "Hits", artist: "Second", compilation: true),
      ])
    #expect(
      try await query(
        db, "SELECT ar.name, al.name FROM albums al JOIN artists ar ON ar.id = al.artistid")
        == [["Various Artists", "Hits"]])
    #expect(
      try await query(
        db, "SELECT s.itunesid, a.name FROM songs s JOIN artists a ON a.id = s.artistid ORDER BY 1")
        == [["1", "First"], ["2", "Second"]])
    #expect(
      try await query(db, "SELECT itunesid, code FROM findings ORDER BY itunesid")
        == [["1", "compilationNoAlbumArtist"], ["2", "compilationNoAlbumArtist"]])
  }

  @Test func albumAndArtistThatNoSongUsesAreRemovedWithAFinding() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(db, &state, "t1", [track(id: 1, artist: "Old Name", sortAlbum: "Album, The")])
    // The artist is renamed and the album gets a different track count.
    try await write(db, &state, "t2", [track(id: 1, artist: "New Name", trackCount: 3)])
    #expect(try await query(db, "SELECT name FROM artists") == [["New Name"]])
    #expect(try await query(db, "SELECT trackcount FROM albums") == [["3"]])
    let findings = try await query(
      db, "SELECT tag, itunesid, code, detail FROM findings ORDER BY id")
    #expect(findings.map { $0[2] } == ["albumRemoved", "artistRemoved"])
    #expect(findings.allSatisfy { $0[0] == "t2" && $0[1] == "NULL" })
    #expect(
      findings[0][3]
        == "owner=\"Old Name\" name=\"Album\" sortname=\"Album, The\" trackcount=2 disccount=1 discnumber=1 compilation=0"
    )
    #expect(findings[1][3] == "name=\"Old Name\" sortname=\"\"")
  }

  @Test func sortNameFollowsTheNewestData() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(db, &state, "t1", [track(id: 1, sortArtist: "Artist, The")])
    try await write(db, &state, "t2", [track(id: 1, sortArtist: "Artist, A")])
    #expect(try await query(db, "SELECT sortname FROM artists") == [["Artist, A"]])
    #expect(try await query(db, "SELECT COUNT(*) FROM artists") == [["1"]])
  }

  @Test func sharedPlayDatesAreListed() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(
      db, &state, "t1",
      [
        track(id: 1, playCount: 1, playDate: Self.feb3),
        track(id: 2, playCount: 1, playDate: Self.feb3),
        track(id: 3, playCount: 1, playDate: Self.mar1),
      ])
    #expect(try await query(db, "SELECT date, songs FROM sharedplaydates") == [[Self.feb3, "2"]])
    #expect(
      try await query(db, "SELECT itunesid, code FROM findings") == [["2", "sharedPlayDate"]])
  }

  @Test func snapshotThatIsNotNewerIsRefusedAndNothingIsWritten() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(db, &state, "t2", [track(id: 1, playCount: 5, playDate: Self.mar1)])
    var older = state
    let changes = older.apply(snapshot("t1", [track(id: 2)]))
    await #expect(throws: ArchiveWriteError.notNewer(tag: "t1", lastTag: "t2")) {
      try await db.writeArchive(changes)
    }
    await #expect(throws: ArchiveWriteError.notNewer(tag: "t2", lastTag: "t2")) {
      try await db.writeArchive(changes.with(tag: "t2"))
    }
    #expect(try await db.archiveLastTag() == "t2")
    #expect(try await query(db, "SELECT itunesid FROM songs") == [["1"]])
  }

  @Test func failureWritesNothing() async throws {
    let db = try await database()
    var state = ArchiveState()
    try await write(db, &state, "t1", [track(id: 1)])
    // A song with no album name fails after the artists have been written.
    var bad = state
    let changes = bad.apply(
      snapshot("t2", [track(id: 2, artist: "Other"), track(id: 3, album: nil)]))
    await #expect(throws: ArchiveWriteError.noAlbumName(persistentID: 3)) {
      try await db.writeArchive(changes)
    }
    #expect(try await db.archiveLastTag() == "t1")
    #expect(try await query(db, "SELECT name FROM artists") == [["Artist"]])
    #expect(try await query(db, "SELECT itunesid FROM songs") == [["1"]])
  }
}

extension SnapshotChanges {
  fileprivate func with(tag: String) -> SnapshotChanges {
    SnapshotChanges(
      tag: tag, songs: songs, plays: plays, playStates: playStates, added: added,
      released: released, findings: findings, activeOtherFindings: activeOtherFindings,
      partialAttributes: partialAttributes, pending: pending)
  }
}
