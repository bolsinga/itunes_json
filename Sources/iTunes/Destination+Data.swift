//
//  Destination+Data.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  func data(for tracks: [Track]) async throws -> Data {
    switch self {
    case .json(_), .jsonGit(_, _):
      try tracks.jsonData()
    case .sqlCode(let context):
      try tracks.sqlData(context)
    case .db(let format):
      try await format.databaseData(tracks: tracks)
    }
  }
}
