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
  fileprivate func fileWriter(for outputFile: URL, context: BackupContext) -> DestinationFileWriting
  {
    let fileWriter: DestinationFileWriting = FileWriter(outputFile: outputFile)
    switch self {
    case .jsonGit:
      return GitBackupWriter(fileWriter: fileWriter, context: context)
    default:
      return fileWriter
    }
  }

  fileprivate var url: URL? {
    switch self {
    case .json(let output), .jsonGit(let output), .sqlCode(let output):
      output.url
    case .db(let storage):
      storage.url
    }
  }

  func emit(_ tracks: [Track], context: BackupContext, schemaOptions: SchemaOptions) async throws {
    enum DataExportError: Error {
      case noTracks
    }

    guard !tracks.isEmpty else {
      throw DataExportError.noTracks
    }

    let tracks = tracks.sorted()

    let data = try await self.data(
      for: tracks, loggingToken: nil, schemaOptions: schemaOptions)

    if let outputFile = self.url {
      try await self.fileWriter(for: outputFile, context: context).write(data: data)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
