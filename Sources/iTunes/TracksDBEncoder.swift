//
//  TracksDBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

protocol TracksDBEncoderContext {
  var context: Database.Context { get }
  var schemaOptions: SchemaOptions { get }
}

struct TracksDBEncoder<Context: TracksDBEncoderContext> {
  let db: Database
  let context: Context
  private let rowEncoder: TrackRowEncoder

  init(context: Context, rowEncoder: TrackRowEncoder) throws {
    self.db = try Database(context: context.context)
    self.context = context
    self.rowEncoder = rowEncoder
  }

  private func emitArtists(schemaConstrainsts: SchemaConstraints) async throws -> [RowArtist: Int64]
  {
    try await db.createTable(rowEncoder.artistTableBuilder, schemaConstraints: schemaConstrainsts)
  }

  private func emitAlbums(artistLookup: [RowArtist: Int64], schemaConstrainsts: SchemaConstraints)
    async throws -> [RowAlbum: Int64]
  {
    try await db.createTable(
      rowEncoder.albumTableBuilder(artistLookup: artistLookup),
      schemaConstraints: schemaConstrainsts)
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

  func encode() async throws {
    try await db.execute("PRAGMA foreign_keys = ON;")
    let schemaOptions = context.schemaOptions
    let artistLookup = try await emitArtists(schemaConstrainsts: schemaOptions.artistConstraints)
    let albumLookup = try await emitAlbums(
      artistLookup: artistLookup, schemaConstrainsts: schemaOptions.albumConstraints)
    let songLookup = try await emitSongs(
      artistLookup: artistLookup, albumLookup: albumLookup,
      schemaConstrainsts: schemaOptions.songConstraints)
    try await emitPlays(
      songLookup: songLookup, schemaConstrainsts: schemaOptions.playsConstraints)
    try await db.execute(rowEncoder.views)
  }

  func close() async {
    await db.close()
  }

  func data() async throws -> Data {
    try await db.data()
  }
}
