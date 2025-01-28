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
  func data(for tracks: [Track]) async throws -> Data {
    switch self {
    case .json(_), .jsonGit(_):
      try tracks.jsonData()
    case .sqlCode(let context):
      try tracks.sqlData(context)
    case .db(let format):
      try await format.database(tracks: tracks)
    case .updateDB(_):
      throw DestinationDataError.noDataForUpdateDB
    }
  }
}
