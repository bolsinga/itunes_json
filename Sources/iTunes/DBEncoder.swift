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

  private func emitArtists() async throws -> [RowArtist: Int64] {
    let rows = rowEncoder.artistRows
    return try await db.createTable(tableSchema: rows.tableSchema, rows: rows.rows) {
      $0.insert.parameters
    }
  }

  private func emitAlbums() async throws -> [RowAlbum: Int64] {
    let rows = rowEncoder.albumRows
    return try await db.createTable(tableSchema: rows.tableSchema, rows: rows.rows) {
      $0.insert.parameters
    }
  }

  private func emitSongs(
    artistLookup: [RowArtist: Int64], albumLookup: [RowAlbum: Int64]
  ) async throws -> [RowSong: Int64] {
    let rows = rowEncoder.songRows
    let artistIDs = rows.rows.reduce(into: [RowSong: Int64]()) {
      $0[$1.song] = artistLookup[$1.artist] ?? -1
    }

    let albumIDs = rows.rows.reduce(into: [RowSong: Int64]()) {
      $0[$1.song] = albumLookup[$1.album] ?? -1
    }

    return try await db.createTable(
      tableSchema: rows.tableSchema, rows: rows.rows.map { $0.song }
    ) {
      $0.insert(artistID: "\(artistIDs[$0])", albumID: "\(albumIDs[$0])").parameters
    }
  }

  @discardableResult
  private func emitPlays(songLookup: [RowSong: Int64]) async throws -> [RowPlay: Int64] {
    let rows = rowEncoder.playRows

    let songIDs = rows.rows.reduce(into: [RowPlay: Int64]()) {
      $0[$1.play] = songLookup[$1.song] ?? -1
    }

    return try await db.createTable(
      tableSchema: rows.tableSchema, rows: rows.rows.map { $0.play! }
    ) {
      $0.insert(songid: "\(songIDs[$0])").parameters
    }
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
