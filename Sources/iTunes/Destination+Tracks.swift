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

protocol DestinationFileWriting {
  func write(data: Data) throws
}

private struct FileWriter: DestinationFileWriting {
  let outputFile: URL

  func write(data: Data) throws {
    try data.write(to: outputFile, options: .atomic)
  }
}

private struct GitWriter: DestinationFileWriting {
  let fileWriter: FileWriter

  func write(data: Data) throws {
    try fileWriter.write(data: data)
    try fileWriter.outputFile.gitAddCommitTagPush(message: String.defaultDestinationName)
  }
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

  fileprivate func fileWriter(_ outputFile: URL) -> DestinationFileWriting {
    let fileWriter = FileWriter(outputFile: outputFile)
    return self.isGit ? GitWriter(fileWriter: fileWriter) : fileWriter
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
        try fileWriter(outputFile).write(data: data)
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
