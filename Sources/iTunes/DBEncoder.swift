//
//  DBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

final class DBEncoder {
  private let db: Database
  private let sqlRowEncoder = SQLRowEncoder()

  init(file: URL) throws {
    self.db = try Database(file: file)
  }

  private func emitKinds() async throws {
    let rows = sqlRowEncoder.kindRows
    guard !rows.rows.isEmpty else { return }

    try await db.execute(rows.table)
  }

  private func emit() async throws {
    try await emitKinds()
  }

  func encode(_ tracks: [Track]) async throws {
    tracks.filter { $0.isSQLEncodable }.forEach { sqlRowEncoder.encode($0) }
    try await emit()
  }
}
