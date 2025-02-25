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
    case .jsonGit(_):
      return GitBackupWriter(fileWriter: fileWriter, context: context)
    default:
      return fileWriter
    }
  }

  fileprivate var output: Output? {
    switch self {
    case .json(let output), .jsonGit(let output):
      return output
    case .sqlCode(let context):
      return context.output
    case .db(let context):
      switch context.storage {
      case .file(let url):
        return .file(url)
      case .memory:
        return nil
      }
    }
  }

  func emit(_ tracks: [Track], context: BackupContext) async throws {
    enum DataExportError: Error {
      case noTracks
      case noOutput
    }

    guard !tracks.isEmpty else {
      throw DataExportError.noTracks
    }

    guard let output else {
      throw DataExportError.noOutput
    }

    let tracks = tracks.sorted()

    let dataProvider = {
      try await self.data(for: tracks)
    }

    switch output {
    case .file(let url):
      try await self.fileWriter(for: url, context: context).write(data: try await dataProvider())
    case .standardOut:
      print("\(try await dataProvider().asUTF8String())")
    }
  }
}
