//
//  Destination+Tracks.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

protocol DestinationFileWriting {
  var outputFile: URL { get }
  func write(data: Data) async throws
}

extension Destination {
  fileprivate func fileWriter(for outputFile: URL, branch: String, tagPrefix: String)
    -> DestinationFileWriting
  {
    let fileWriter: DestinationFileWriting = FileWriter(outputFile: outputFile)
    switch self {
    case .jsonGit:
      return GitBackupWriter(fileWriter: fileWriter, branch: branch, tagPrefix: tagPrefix)
    default:
      return fileWriter
    }
  }

  public func emit(
    _ tracks: [Track], loggingToken: String?, branch: String, tagPrefix: String,
    schemaConstraints: SchemaConstraints
  )
    async throws
  {
    enum DataExportError: Error {
      case noTracks
    }

    guard !tracks.isEmpty else {
      throw DataExportError.noTracks
    }

    let tracks = tracks.sorted()

    switch self {
    case .json(let output), .sqlCode(let output), .jsonGit(let output):
      let data = try self.data(
        for: tracks, loggingToken: loggingToken, schemaConstraints: schemaConstraints)

      if let outputFile = output.url {
        try await self.fileWriter(for: outputFile, branch: branch, tagPrefix: tagPrefix).write(
          data: data)
      } else {
        print("\(try data.asUTF8String())")
      }
    case .db(let outputFile):
      let data = try await tracks.database(
        storage: .memory, loggingToken: loggingToken, schemaConstrainsts: schemaConstraints)
      try FileWriter(outputFile: outputFile).write(data: data)
    }
  }
}
