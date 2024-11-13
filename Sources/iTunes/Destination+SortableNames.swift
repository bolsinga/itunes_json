//
//  Destination+SortableNames.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/14/24.
//

import Foundation
import os

extension Destination {
  public func emitArtists(for tracks: [Track], outputFile: URL?) async throws {
    let logger = Logger(type: "validation", category: "artist", token: nil)
    let names = Array(
      Set(tracks.filter { $0.isSQLEncodable }.map { $0.artistName(logger: logger) }))
    try await self.emit(names, outputFile: outputFile, branch: "artists") {
      try self.data(for: $0)
    } databaseBuilder: {
      guard let outputFile else {
        preconditionFailure("Should have been caught during ParasableArguments.validate().")
      }

      try await $0.database(file: outputFile)
    }
  }

  func data(for items: [SortableName]) throws -> Data {
    switch self {
    case .json:
      return try items.jsonData()
    case .sqlCode:
      return try items.sqlData()
    case .db, .jsonGit:
      preconditionFailure("No Data for \(self)")
    }
  }
}
