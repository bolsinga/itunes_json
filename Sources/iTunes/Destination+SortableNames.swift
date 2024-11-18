//
//  Destination+SortableNames.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/14/24.
//

import Foundation
import os

extension Destination {
  public func emitSortableNames(for tracks: [Track], outputFile: URL?, descriptiveName: String)
    async throws
  {
    let logger = Logger(type: "validation", category: descriptiveName, token: nil)
    let names = Array(
      Set(tracks.filter { $0.isSQLEncodable }.map { $0.artistName(logger: logger) }))
    // The tagPrefix will be able to change based upon the descriptiveName.
    try await self.emit(names, outputFile: outputFile, branch: descriptiveName, tagPrefix: "iTunes")
    {
      try self.data(for: $0, tableName: descriptiveName)
    } databaseBuilder: {
      guard let outputFile else {
        preconditionFailure("Should have been caught during ParasableArguments.validate().")
      }

      try await $0.database(file: outputFile, tableName: descriptiveName)
    }
  }

  func data(for items: [SortableName], tableName: String) throws -> Data {
    switch self {
    case .json:
      return try items.jsonData()
    case .sqlCode:
      return try items.sqlData(tableName: tableName)
    case .db, .jsonGit:
      preconditionFailure("No Data for \(self)")
    }
  }
}
