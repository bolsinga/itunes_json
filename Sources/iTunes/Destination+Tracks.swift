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
  fileprivate func fileWriter(
    for outputFile: URL, branch: String, tagPrefix: String, version: String
  )
    -> DestinationFileWriting
  {
    let fileWriter: DestinationFileWriting = FileWriter(outputFile: outputFile)
    switch self {
    case .jsonGit:
      return GitBackupWriter(
        fileWriter: fileWriter, branch: branch, tagPrefix: tagPrefix, version: version)
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

  func emit(
    _ tracks: [Track], branch: String, tagPrefix: String, version: String,
    schemaOptions: LaxSchemaOptions
  ) async throws {
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
      try await self.fileWriter(
        for: outputFile, branch: branch, tagPrefix: tagPrefix, version: version
      ).write(
        data: data)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
