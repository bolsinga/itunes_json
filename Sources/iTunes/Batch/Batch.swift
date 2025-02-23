//
//  Batch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let batch = Logger(category: "batch")
}

enum Batch: CaseIterable {
  /// Normalized SQL
  case sql
  /// Normalized Database
  case db
  /// Flat Database
  case flat
}

extension Tag where Item == Data {
  fileprivate func write(to directory: URL, pathExtension: String) throws {
    Logger.batch.info("Write: \(tag)")

    let url = directory.appending(path: tag).appendingPathExtension(pathExtension)
    try item.write(to: url)
  }
}

extension Batch {
  func build(
    _ configuration: GitTagData.Configuration, outputDirectory: URL,
    schemaOptions: SchemaOptions
  ) async throws {
    var patchedTracksData = try await GitTagData(configuration: configuration)
      .transformTracks { tag, tracks in
        let destination = {
          switch self {
          case .sql:
            Destination.sqlCode(
              SQLCodeContext(
                output: .standardOut, schemaOptions: schemaOptions, loggingToken: "batch-\(tag)"))
          case .db:
            Destination.db(
              .normalized(
                DatabaseContext(
                  storage: .memory, schemaOptions: schemaOptions, loggingToken: "batch-\(tag)")))
          case .flat:
            Destination.db(
              .flat(FlatTracksDatabaseContext(storage: .memory, loggingToken: "batch-\(tag)")))
          }
        }()

        return try await destination.data(for: tracks)
      }

    let pathExtension = {
      switch self {
      case .sql:
        "sql"
      case .db, .flat:
        "db"
      }
    }()

    for tagData in patchedTracksData.reversed() {
      patchedTracksData.removeLast()

      try tagData.write(to: outputDirectory, pathExtension: pathExtension)
    }
  }
}
