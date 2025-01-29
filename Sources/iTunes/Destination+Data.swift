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
    case .json(_), .jsonGit(_):
      try tracks.jsonData()
    case .sqlCode(let context):
      try tracks.sqlData(loggingToken: loggingToken, schemaOptions: context.schemaOptions)
    case .db(let storage):
      try await tracks.database(
        context: Database.Context(storage: storage, loggingToken: loggingToken),
        schemaOptions: schemaOptions)
    case .updateDB(_):
      throw DestinationDataError.noDataForUpdateDB
    }
  }
}
