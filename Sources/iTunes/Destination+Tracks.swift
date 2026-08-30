//
//  Destination+Tracks.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Output {
  fileprivate func emit(_ data: Data) throws {
    switch self {
    case .file(let url):
      try data.write(to: url, options: .atomic)
    case .standardOut:
      print("\(try data.asUTF8String())")
    }
  }
}

extension Destination {
  func emit(_ tracks: [Track]) async throws {
    enum DataExportError: Error {
      case noTracks
      case noMemoryDatabase
    }

    guard !tracks.isEmpty else {
      throw DataExportError.noTracks
    }

    let tracks = tracks.sorted()

    let data = try await data(for: tracks)

    switch self {
    case .json(let output):
      try output.emit(data)
    case .jsonGit(let context):
      try await context.write(data: data)
    case .sqlCode(let context):
      try context.output.emit(data)
    case .db(let format):
      switch format.storage {
      case .file(let url):
        try Output.file(url).emit(data)
      case .memory:
        throw DataExportError.noMemoryDatabase
      }
    }
  }
}
