//
//  Batch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import Foundation
import iTunes

enum Batch: CaseIterable {
  case sql
  case db
}

extension Batch {
  func build(
    _ configuration: GitTagData.Configuration, outputDirectory: URL,
    schemaConstraints: SchemaConstraints
  ) async throws {
    var patchedTracksData = try await GitTagData(configuration: configuration)
      .transformTaggedTracks {
        switch self {
        case .sql:
          try await Destination.sqlCode(.standardOut).data(
            for: $0, loggingToken: "batch", schemaConstraints: schemaConstraints)
        case .db:
          try await Destination.db(.memory).data(
            for: $0, loggingToken: "batch", schemaConstraints: schemaConstraints)
        }
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
