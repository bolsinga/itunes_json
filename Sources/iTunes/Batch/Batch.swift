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
  case sql
  case db
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
      .transformTracks {
        let destination = {
          switch self {
          case .sql:
            Destination.sqlCode(SQLCodeContext(output: .standardOut))
          case .db:
            Destination.db(.memory)
          }
        }()

        return try await destination.data(
          for: $1, loggingToken: "batch-\($0)", schemaOptions: schemaOptions)
      }

    let pathExtension = {
      switch self {
      case .sql:
        "sql"
      case .db:
        "db"
      }
    }()

    for tagData in patchedTracksData.reversed() {
      patchedTracksData.removeLast()

      try tagData.write(to: outputDirectory, pathExtension: pathExtension)
    }
  }
}
