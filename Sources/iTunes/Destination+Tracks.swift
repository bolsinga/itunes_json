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
  public func emit(_ tracks: [Track], outputFile: URL?) throws {
    guard tracks.count > 0 else {
      throw DataExportError.noTracks
    }

    let data = try self.data(for: tracks)

    if let outputFile {
      try data.write(to: outputFile, options: .atomic)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
