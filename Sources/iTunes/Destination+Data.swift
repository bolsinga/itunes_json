//
//  Destination+Data.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

private enum DestinationDataError: Error {
  case noDataForUpdateDB
}

extension Destination {
  func data(for tracks: [Track], loggingToken: String?, schemaOptions: SchemaOptions)
    async throws -> Data
  {
    switch self {
    case .json, .jsonGit:
      try tracks.jsonData()
    case .sqlCode:
      try tracks.sqlData(loggingToken: loggingToken, schemaOptions: schemaOptions)
    case .db:
      try await tracks.database(
        storage: .memory, loggingToken: loggingToken, schemaOptions: schemaOptions)
    case .updateDB:
      throw DestinationDataError.noDataForUpdateDB
    }
  }
}
