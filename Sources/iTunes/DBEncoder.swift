//
//  DBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

final class DBEncoder {
  private let db: Database
  private let rowEncoder = TrackRowEncoder()

  init(file: URL) throws {
    self.db = try Database(file: file)
  }

  private func emit<T: SQLBindableInsert>(table: String, rows: [T], ids: [[Int64]] = [])
    async throws -> [T: Int64]
  {
    guard !rows.isEmpty else { return [:] }

    try await db.execute(table)

    let statement = try await db.prepare(T.insertBinding)

    let ids = ids.isEmpty ? Array(repeating: [], count: rows.count) : ids

    var lookup = [T: Int64]()
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

  private func emit() async throws {
    let kindLookup = try await emitKinds()
    let artistLookup = try await emitArtists()
    let albumLookup = try await emitAlbums()
  }

  func encode(_ tracks: [Track]) async throws {
    tracks.filter { $0.isSQLEncodable }.forEach { rowEncoder.encode($0) }
    try await emit()
  }
}
