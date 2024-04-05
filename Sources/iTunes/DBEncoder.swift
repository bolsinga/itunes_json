//
//  DBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

final class DBEncoder {
  private let db: Database
  private let rowEncoder: TrackRowEncoder

  init(file: URL, rowEncoder: TrackRowEncoder, loggingToken: String?) throws {
    self.db = try Database(file: file, loggingToken: loggingToken)
    self.rowEncoder = rowEncoder
  }

  private func emit<T: SQLBindableInsert & Sendable>(table: String, rows: [T], ids: [[Int64]] = [])
    async throws -> [T: Int64]
  {
    guard !rows.isEmpty else { return [:] }

    return try await db.transaction { db in
      try db.execute(table)

      let statement = try db.prepare(T.insertBinding)

      let ids = ids.isEmpty ? Array(repeating: [], count: rows.count) : ids

      var lookup = [T: Int64](minimumCapacity: rows.count)
      for (row, ids) in zip(rows, ids) {
        try row.bindInsert(db: db, statement: statement, ids: ids)
        try statement.execute(db: db)
        lookup[row] = db.lastID
      }
      return lookup
    }
  }

  private func emitArtists() async throws -> [RowArtist: Int64] {
    let rows = rowEncoder.artistRows
    return try await emit(table: rows.table, rows: rows.rows)
  }

  private func emitAlbums() async throws -> [RowAlbum: Int64] {
    let rows = rowEncoder.albumRows
    return try await emit(table: rows.table, rows: rows.rows)
  }

  private func emitSongs(
    artistLookup: [RowArtist: Int64], albumLookup: [RowAlbum: Int64]
  ) async throws -> [RowSong: Int64] {
    let rows = rowEncoder.songRows
    let ids = rows.rows.map { [artistLookup[$0.artist] ?? -1, albumLookup[$0.album] ?? -1] }
    return try await emit(table: rows.table, rows: rows.rows.map { $0.song }, ids: ids)
  }

  @discardableResult
  private func emitPlays(songLookup: [RowSong: Int64]) async throws -> [RowPlay: Int64] {
    let rows = rowEncoder.playRows
    let ids = rows.rows.map { [songLookup[$0.song] ?? -1] }
    return try await emit(table: rows.table, rows: rows.rows.map { $0.play! }, ids: ids)
  }

  func encode() async throws {
    try await db.execute("PRAGMA foreign_keys = ON;")
    let artistLookup = try await emitArtists()
    let albumLookup = try await emitAlbums()
    let songLookup = try await emitSongs(artistLookup: artistLookup, albumLookup: albumLookup)
    try await emitPlays(songLookup: songLookup)
    try await db.execute(rowEncoder.views)
  }

  func close() async {
    await db.close()
  }
}
