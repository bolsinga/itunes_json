//
//  Destination+Data.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  public func data(for tracks: [Track], loggingToken: String?) throws -> Data {
    switch self {
    case .json, .jsonGit:
      return try tracks.jsonData()
    case .sqlCode:
      return try tracks.sqlData(loggingToken: loggingToken)
    case .db:
      preconditionFailure("No Data for db")
    }
  }
}
