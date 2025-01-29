//
//  Destination+UpdateDB.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/11/25.
//

import Foundation

extension Destination {
  func updateDB(at url: URL, tracks: [Track]) async throws {
    enum UpdateDBError: Error {
      case invalidDestination
    }
    switch self {
    case .json(_), .jsonGit(_), .sqlCode(_), .db(_):
      throw UpdateDBError.invalidDestination
    case .updateDB(let context):
      let sourceDB: Database = try await tracks.database(context)
      try await sourceDB.mergeIntoDB(at: url)
    }
  }
}
