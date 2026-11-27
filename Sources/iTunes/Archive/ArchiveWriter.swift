//
//  ArchiveWriter.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let archiveWriter = Logger(category: "archiveWriter")
}

enum ArchiveWriteError: Error, Equatable {
  /// The snapshot is not newer than the last one that was applied.
  case notNewer(tag: String, lastTag: String)
  case noArtist(persistentID: UInt)
  case noAlbumName(persistentID: UInt)
}

extension Database {
  /// Turns on foreign keys and creates the tables and views if they are not there. Call it each
  /// time an archive is opened, because the pragma is for one connection.
  func prepareArchive() throws {
    try execute("PRAGMA foreign_keys = ON")
    try transaction { db in
      try db.execute(ArchiveSchema.tables)
      try db.execute(ArchiveSchema.views)
      try db.setArchiveState("schemaversion", ArchiveSchema.version)
      try db.setArchiveState("toolversion", iTunesVersion)
    }
  }

  /// The tag of the newest snapshot that was applied. Nil for an archive that is empty.
  func archiveLastTag() throws -> String? {
    try transaction { db in try db.readArchiveState("lasttag") }
  }

  /// Writes what one snapshot changes, and the tag, in one transaction. A snapshot that is not
  /// newer than the last one is refused. A failure writes nothing.
  ///
  /// The order of tags is the caller's. By default it is the order of the strings, as the old
  /// `archive` has it.
  func writeArchive(
    _ changes: SnapshotChanges,
    isOrderedBefore: @escaping @Sendable (String, String) -> Bool = {
      $0 < $1
    }
  ) throws {
    try transaction { db in
      if let last = try db.readArchiveState("lasttag"), !isOrderedBefore(last, changes.tag) {
        throw ArchiveWriteError.notNewer(tag: changes.tag, lastTag: last)
      }
      try db.writeCatalog(changes)
      try db.writeTimeline(changes)
      try db.writeFindings(changes.findings)
      try db.removeUnusedRows(tag: changes.tag)
      try db.writeCarryOver(changes)
      try db.setArchiveState("lasttag", changes.tag)
    }
  }
}

// MARK: - Statements

extension Database {
  func prepare(_ sql: String) throws -> Database.PreparedStatement {
    try Database.PreparedStatement(string: sql, db: self)
  }

  @discardableResult
  func run(_ statement: Database.PreparedStatement, _ arguments: [Value]) throws
    -> [Row]
  {
    if !arguments.isEmpty { try statement.bind(arguments: arguments) { errorString } }
    return try statement.execute { errorString }
  }

  fileprivate func setArchiveState(_ key: String, _ value: String) throws {
    let statement = try prepare(
      "INSERT INTO archivestate (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value"
    )
    defer { statement.close() }
    try run(statement, [.string(key), .string(value)])
  }

  func readArchiveState(_ key: String) throws -> String? {
    let statement = try prepare("SELECT value FROM archivestate WHERE key = ?")
    defer { statement.close() }
    return try run(statement, [.string(key)]).first?.first?.value.string
  }
}

// MARK: - Catalog

extension Array where Element == String {
  fileprivate var mostCommon: String {
    // Most common first, then alphabetical.
    Dictionary(grouping: self, by: { $0 }).map { ($0.key, $0.value.count) }
      .sorted { ($1.1, $0.0) < ($0.1, $1.0) }.first?.0 ?? ""
  }
}

extension Database {
  /// Sets the artists, albums and songs of the snapshot to what it has. A song that is not in the
  /// snapshot keeps its row.
  fileprivate func writeCatalog(_ changes: SnapshotChanges) throws {
    // Artists: the sort name is the one the artist's tracks have. A name that is only the owner of
    // an album takes the sort name of the owner.
    var trackArtistSort = [String: String]()
    var ownerSorts = [String: [String]]()
    for track in changes.songs {
      guard let artist = track.artistName else {
        throw ArchiveWriteError.noArtist(persistentID: track.persistentID)
      }
      trackArtistSort[artist.name] =
        trackArtistSort[artist.name].flatMap { $0.isEmpty ? nil : $0 }
        ?? artist.sorted
      let owner = track.albumOwner.name
      if !owner.sorted.isEmpty { ownerSorts[owner.name, default: []].append(owner.sorted) }
    }
    let names = Set(trackArtistSort.keys).union(
      changes.songs.map { $0.albumOwner.name.name }
    ).sorted()

    let upsertArtist = try prepare(
      "INSERT INTO artists (name, sortname) VALUES (?, ?) ON CONFLICT(name) DO UPDATE SET sortname = excluded.sortname"
    )
    let selectArtist = try prepare("SELECT id FROM artists WHERE name = ?")
    defer {
      upsertArtist.close()
      selectArtist.close()
    }
    var artistIDs = [String: Int64]()
    for name in names {
      let sortName =
        trackArtistSort[name].flatMap { $0.isEmpty ? nil : $0 } ?? ownerSorts[name]?.mostCommon
        ?? ""
      try run(upsertArtist, [.string(name), .string(sortName)])
      guard let id = try run(selectArtist, [.string(name)]).first?.first?.value.integer else {
        throw DatabaseError.cannotStep("no artist \(name)")
      }
      artistIDs[name] = id
    }

    // Albums: an album is its identity. The sort name is the one its tracks have.
    var albumSorts = [AlbumIdentity: [String]]()
    for track in changes.songs {
      guard let album = track.album, !album.isEmpty else {
        throw ArchiveWriteError.noAlbumName(persistentID: track.persistentID)
      }
      let sorted = SortableName(name: album, sorted: track.sortAlbum ?? "").sorted
      albumSorts[track.albumIdentity, default: []].append(sorted)
    }
    let upsertAlbum = try prepare(
      """
      INSERT INTO albums (artistid, name, sortname, trackcount, disccount, discnumber, compilation)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(artistid, name, trackcount, disccount, discnumber, compilation)
      DO UPDATE SET sortname = excluded.sortname
      """)
    let selectAlbum = try prepare(
      """
      SELECT id FROM albums WHERE artistid = ? AND name = ? AND trackcount = ? AND disccount = ?
      AND discnumber = ? AND compilation = ?
      """)
    defer {
      upsertAlbum.close()
      selectAlbum.close()
    }
    var albumIDs = [AlbumIdentity: Int64]()
    let identities = albumSorts.keys.sorted {
      ($0.owner, $0.name, $0.discNumber, $0.trackCount, $0.discCount, $0.compilation ? 1 : 0)
        < ($1.owner, $1.name, $1.discNumber, $1.trackCount, $1.discCount, $1.compilation ? 1 : 0)
    }
    for identity in identities {
      let key: [Value] = [
        .integer(artistIDs[identity.owner] ?? 0), .string(identity.name),
        .integer(Int64(identity.trackCount)), .integer(Int64(identity.discCount)),
        .integer(Int64(identity.discNumber)), .integer(identity.compilation ? 1 : 0),
      ]
      let sortName = (albumSorts[identity] ?? []).filter { !$0.isEmpty }.mostCommon
      try run(
        upsertAlbum,
        [key[0], key[1], .string(sortName), key[2], key[3], key[4], key[5]])
      guard let id = try run(selectAlbum, key).first?.first?.value.integer else {
        throw DatabaseError.cannotStep("no album \(identity.name)")
      }
      albumIDs[identity] = id
    }

    // Songs.
    let upsertSong = try prepare(
      """
      INSERT INTO songs (itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, comments, lastseen)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(itunesid) DO UPDATE SET name = excluded.name, sortname = excluded.sortname,
        artistid = excluded.artistid, albumid = excluded.albumid, composer = excluded.composer,
        tracknumber = excluded.tracknumber, year = excluded.year, duration = excluded.duration,
        comments = excluded.comments, lastseen = excluded.lastseen
      """)
    defer { upsertSong.close() }
    for track in changes.songs {
      guard let artist = track.artistName else {
        throw ArchiveWriteError.noArtist(persistentID: track.persistentID)
      }
      let song = track.songName
      try run(
        upsertSong,
        [
          .string(track.songPersistentID), .string(song.name), .string(song.sorted),
          .integer(artistIDs[artist.name] ?? 0), .integer(albumIDs[track.albumIdentity] ?? 0),
          .string(track.songComposer), .integer(Int64(track.trackNumber ?? 0)),
          .integer(Int64(track.year ?? 0)), .integer(Int64(track.totalTime ?? 0)),
          .string(track.songComments), .string(changes.tag),
        ])
    }
  }
}

// MARK: - Timeline

extension Database {
  fileprivate func writeTimeline(_ changes: SnapshotChanges) throws {
    let insertAdded = try prepare("INSERT OR IGNORE INTO added (itunesid, date) VALUES (?, ?)")
    let insertReleased = try prepare(
      "INSERT OR IGNORE INTO released (itunesid, date) VALUES (?, ?)")
    let insertPlay = try prepare(
      "INSERT INTO plays (itunesid, date, delta, count, tag) VALUES (?, ?, ?, ?, ?)")
    let upsertState = try prepare(
      "INSERT INTO playstate (itunesid, seencount, seendate) VALUES (?, ?, ?) ON CONFLICT(itunesid) DO UPDATE SET seencount = excluded.seencount, seendate = excluded.seendate"
    )
    defer {
      insertAdded.close()
      insertReleased.close()
      insertPlay.close()
      upsertState.close()
    }
    for row in changes.added {
      try run(insertAdded, [.string(String(row.persistentID)), .string(row.date)])
    }
    for row in changes.released {
      try run(insertReleased, [.string(String(row.persistentID)), .string(row.date)])
    }
    for play in changes.plays {
      try run(
        insertPlay,
        [
          .string(String(play.persistentID)), .string(play.date), .integer(Int64(play.delta)),
          .integer(Int64(play.count)), .string(play.tag),
        ])
    }
    for (id, state) in changes.playStates.sorted(by: { $0.key < $1.key }) {
      try run(
        upsertState,
        [.string(String(id)), .integer(Int64(state.seenCount)), .string(state.seenDate)])
    }
  }
}

// MARK: - Findings

extension Database {
  fileprivate func writeFindings(_ findings: [FindingRecord]) throws {
    let insert = try prepare(
      "INSERT INTO findings (tag, itunesid, code, detail) VALUES (?, ?, ?, ?)")
    defer { insert.close() }
    for finding in findings {
      try run(
        insert,
        [
          .string(finding.tag), finding.persistentID.map { .string(String($0)) } ?? .null,
          .string(finding.code), .string(finding.detail),
        ])
      Logger.archiveWriter.info(
        "\(finding.tag, privacy: .public) \(finding.persistentID.map(String.init) ?? "-", privacy: .public) \(finding.code, privacy: .public) \(finding.detail, privacy: .public)"
      )
    }
  }

  /// Deletes an album that no song refers to, and then an artist that no song or album refers to.
  /// Each is written as a finding with the whole row first.
  fileprivate func removeUnusedRows(tag: String) throws {
    let albums = try prepare(
      """
      SELECT al.id, ar.name, al.name, al.sortname, al.trackcount, al.disccount, al.discnumber, al.compilation
      FROM albums al JOIN artists ar ON ar.id = al.artistid
      WHERE al.id NOT IN (SELECT albumid FROM songs) ORDER BY al.id
      """)
    let deleteAlbum = try prepare("DELETE FROM albums WHERE id = ?")
    let artists = try prepare(
      """
      SELECT id, name, sortname FROM artists
      WHERE id NOT IN (SELECT artistid FROM songs) AND id NOT IN (SELECT artistid FROM albums)
      ORDER BY id
      """)
    let deleteArtist = try prepare("DELETE FROM artists WHERE id = ?")
    defer {
      albums.close()
      deleteAlbum.close()
      artists.close()
      deleteArtist.close()
    }

    var removals = [FindingRecord]()
    for row in try run(albums, []) {
      let values = row.map(\.value)
      guard let id = values[0].integer else { continue }
      removals.append(
        FindingRecord(
          tag: tag, persistentID: nil, code: "albumRemoved",
          detail:
            "owner=\"\(values[1])\" name=\"\(values[2])\" sortname=\"\(values[3])\" trackcount=\(values[4]) disccount=\(values[5]) discnumber=\(values[6]) compilation=\(values[7])"
        ))
      try run(deleteAlbum, [.integer(id)])
    }
    for row in try run(artists, []) {
      let values = row.map(\.value)
      guard let id = values[0].integer else { continue }
      removals.append(
        FindingRecord(
          tag: tag, persistentID: nil, code: "artistRemoved",
          detail: "name=\"\(values[1])\" sortname=\"\(values[2])\""))
      try run(deleteArtist, [.integer(id)])
    }
    try writeFindings(removals)
  }
}

// MARK: - Carry over

extension ArchiveState {
  /// The keys of `archivestate` that hold what an update needs and the tables do not have.
  static let activeFindingsKey = "activefindings"
  static let partialAttributesKey = "partialattributes"
}

extension Database {
  /// Keeps the findings that the next snapshot has to compare with, and the required numbers of
  /// the songs that have no row. See `loadArchiveState()`.
  fileprivate func writeCarryOver(_ changes: SnapshotChanges) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    try setArchiveState(
      ArchiveState.activeFindingsKey,
      try encoder.encode(changes.activeOtherFindings).asUTF8String())
    try setArchiveState(
      ArchiveState.partialAttributesKey,
      try encoder.encode(
        Dictionary(
          uniqueKeysWithValues: changes.partialAttributes.map { (String($0.key), $0.value) })
      ).asUTF8String())
  }
}
