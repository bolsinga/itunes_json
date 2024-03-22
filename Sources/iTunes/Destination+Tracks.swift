//
//  Destination+Tracks.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

enum DataExportError: Error {
  case noTracks
}

extension Destination {
  fileprivate var isGit: Bool {
    switch self {
    case .jsonGit:
      return true
    default:
      return false
    }
  }

  public func emit(_ tracks: [Track], outputFile: URL?, loggingToken: String?) async throws {
    guard tracks.count > 0 else {
      throw DataExportError.noTracks
    }

    let tracks = tracks.sorted()

    switch self {
    case .json, .sqlCode, .jsonGit:
      let data = try self.data(for: tracks, loggingToken: loggingToken)

      if let outputFile {
        try data.write(to: outputFile, options: .atomic)

        if self.isGit {
          try outputFile.gitAddCommitTagPush(message: String.defaultDestinationName)
        }
      } else {
        print("\(try data.asUTF8String())")
      }
    case .db:
      guard let outputFile else {
        preconditionFailure("Should have been caught during ParasableArguments.validate().")
      }

      try await tracks.database(file: outputFile, loggingToken: loggingToken)
    }
  }
}
