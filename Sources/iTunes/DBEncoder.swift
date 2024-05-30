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
    try await db.createTable(rowEncoder.artistTableBuilder)
  }

  private func emitAlbums() async throws -> [RowAlbum: Int64] {
    try await db.createTable(rowEncoder.albumTableBuilder)
  }

  private func emitSongs(
    artistLookup: [RowArtist: Int64], albumLookup: [RowAlbum: Int64]
  ) async throws -> [RowSong: Int64] {
    try await db.createTable(
      rowEncoder.songTableBuilder(artistLookup: artistLookup, albumLookup: albumLookup))
  }

  @discardableResult
  private func emitPlays(songLookup: [RowSong: Int64]) async throws -> [RowPlay: Int64] {
    try await db.createTable(rowEncoder.playTableBuilder(songLookup))
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
