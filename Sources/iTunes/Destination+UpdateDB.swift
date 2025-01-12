//
//  Destination+UpdateDB.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/11/25.
//

import Foundation

extension Destination {
  func updateDB(at url: URL, tracks: [Track], loggingToken: String?, schemaOptions: SchemaOptions)
    async throws
  {
    let sourceDB: Database = try await tracks.database(
      storage: .memory, loggingToken: loggingToken, schemaOptions: schemaOptions)
    try await sourceDB.mergeIntoDB(at: url)
  }
}
