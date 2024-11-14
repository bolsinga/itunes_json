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
  var outputFile: URL { get }
  func write(data: Data) throws
}

extension Destination {
  fileprivate func fileWriter(for outputFile: URL, branch: String) -> DestinationFileWriting {
    let fileWriter: DestinationFileWriting = FileWriter(outputFile: outputFile)
    switch self {
    case .jsonGit:
      return GitWriter(fileWriter: fileWriter, branch: branch)
    default:
      return fileWriter
    }
  }

  public func emit<T: Comparable>(
    _ items: [T], outputFile: URL?, branch: String, dataBuilder: ([T]) throws -> Data,
    databaseBuilder: ([T]) async throws -> Void
  )
    async throws
  {
    guard !items.isEmpty else {
      throw DataExportError.noTracks
    }

    let items = items.sorted()

    switch self {
    case .json, .sqlCode, .jsonGit:
      let data = try dataBuilder(items)
      if let outputFile {
        try self.fileWriter(for: outputFile, branch: branch).write(data: data)
      } else {
        print("\(try data.asUTF8String())")
      }
    case .db:
      try await databaseBuilder(items)
    }
  }
}
