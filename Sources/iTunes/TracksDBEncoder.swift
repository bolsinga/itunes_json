//
//  TracksDBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

struct TracksDBEncoder {
  private let db: Database
  private let rowEncoder: TrackRowEncoder

  init(file: URL, rowEncoder: TrackRowEncoder, loggingToken: String?) throws {
    self.db = try Database(file: file, loggingToken: loggingToken)
    self.rowEncoder = rowEncoder
  }

  private func emitArtists(schemaConstrainsts: SchemaConstraints) async throws -> [RowArtist: Int64]
  {
    try await db.createTable(rowEncoder.artistTableBuilder, schemaConstraints: schemaConstrainsts)
  }

  private func emitAlbums(schemaConstrainsts: SchemaConstraints) async throws -> [RowAlbum: Int64] {
    try await db.createTable(rowEncoder.albumTableBuilder, schemaConstraints: schemaConstrainsts)
  }

  private func emitSongs(
    artistLookup: [RowArtist: Int64], albumLookup: [RowAlbum: Int64],
    schemaConstrainsts: SchemaConstraints
  ) async throws -> [RowSong: Int64] {
    try await db.createTable(
      rowEncoder.songTableBuilder(artistLookup: artistLookup, albumLookup: albumLookup),
      schemaConstraints: schemaConstrainsts)
  }

  @discardableResult
  private func emitPlays(songLookup: [RowSong: Int64], schemaConstrainsts: SchemaConstraints)
    async throws -> [RowPlay: Int64]
  {
    try await db.createTable(
      rowEncoder.playTableBuilder(songLookup), schemaConstraints: schemaConstrainsts)
  }

  func encode(schemaConstrainsts: SchemaConstraints) async throws {
    try await db.execute("PRAGMA foreign_keys = ON;")
    let artistLookup = try await emitArtists(schemaConstrainsts: schemaConstrainsts)
    let albumLookup = try await emitAlbums(schemaConstrainsts: schemaConstrainsts)
    let songLookup = try await emitSongs(
      artistLookup: artistLookup, albumLookup: albumLookup, schemaConstrainsts: schemaConstrainsts)
    try await emitPlays(songLookup: songLookup, schemaConstrainsts: schemaConstrainsts)
    try await db.execute(rowEncoder.views)
  }

  func close() async {
    await db.close()
  }
}
