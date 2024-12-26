//
//  Batch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import Foundation

enum Batch: CaseIterable {
  case sql
  case db
}

extension Batch {
  func build(
    _ configuration: GitTagData.Configuration, outputDirectory: URL,
    laxSchemaOptions: LaxSchemaOptions
  ) async throws {
    var patchedTracksData = try await GitTagData(configuration: configuration)
      .transformTaggedTracks {
        let destination = {
          switch self {
          case .sql:
            Destination.sqlCode(.standardOut)
          case .db:
            Destination.db(.memory)
          }
        }()

        return try await destination.data(
          for: $1, loggingToken: "batch-\($0)", laxSchemaOptions: laxSchemaOptions)
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
