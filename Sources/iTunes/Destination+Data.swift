//
//  Destination+Data.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  public func data(for tracks: [Track], loggingToken: String?, schemaConstraints: SchemaConstraints)
    throws -> Data
  {
    enum DestinationDataError: Error {
      case notImplemented
    }
    switch self {
    case .json, .jsonGit:
      return try tracks.jsonData()
    case .sqlCode:
      return try tracks.sqlData(loggingToken: loggingToken, schemaConstraints: schemaConstraints)
    case .db:
      throw DestinationDataError.notImplemented
    }
  }
}
