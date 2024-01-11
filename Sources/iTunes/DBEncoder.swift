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

  init(file: URL, minimumCapacity: Int) throws {
    self.db = try Database(file: file)
    self.rowEncoder = TrackRowEncoder(minimumCapacity: minimumCapacity)
  }

  private func emit<T: SQLBindableInsert>(table: String, rows: [T], ids: [[Int64]] = [])
    async throws -> [T: Int64]
  {
    guard !rows.isEmpty else { return [:] }

    try await db.execute(table)

    let statement = try await db.prepare(T.insertBinding)

    let ids = ids.isEmpty ? Array(repeating: [], count: rows.count) : ids

    var lookup = [T: Int64](minimumCapacity: rows.count)
    for (row, ids) in zip(rows, ids) {
      try row.bindInsert(db: db, statement: statement, ids: ids)
      try statement.execute(db: db)
      lookup[row] = await db.lastID
    }
    return lookup
  }

  private func emitKinds() async throws -> [RowKind: Int64] {
    let rows = rowEncoder.kindRows
    return try await emit(table: rows.table, rows: rows.rows)
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
    artistLookup: [RowArtist: Int64], albumLookup: [RowAlbum: Int64], kindLookup: [RowKind: Int64]
  ) async throws -> [RowSong: Int64] {
    let rows = rowEncoder.songRows
    let ids = rows.rows.map {
      [artistLookup[$0.artist] ?? -1, albumLookup[$0.album] ?? -1, kindLookup[$0.kind] ?? -1]
    }
    return try await emit(table: rows.table, rows: rows.rows.map { $0.song }, ids: ids)
  }

  @discardableResult
  private func emitPlays(songLookup: [RowSong: Int64]) async throws -> [RowPlay: Int64] {
    let rows = rowEncoder.playRows
    let ids = rows.rows.map { [songLookup[$0.song] ?? -1] }
    return try await emit(table: rows.table, rows: rows.rows.map { $0.play! }, ids: ids)
  }

  private func emit() async throws {
    let kindLookup = try await emitKinds()
    let artistLookup = try await emitArtists()
    let albumLookup = try await emitAlbums()
    let songLookup = try await emitSongs(
      artistLookup: artistLookup, albumLookup: albumLookup, kindLookup: kindLookup)
    try await emitPlays(songLookup: songLookup)
  }

  func encode(_ tracks: [Track]) async throws {
    tracks.filter { $0.isSQLEncodable }.forEach { rowEncoder.encode($0) }
    try await emit()
  }
}
