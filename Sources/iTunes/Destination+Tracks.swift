//
//  Destination+Tracks.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Destination {
  public func emit(_ tracks: [Track], outputFile: URL?) throws {
    let data = try tracks.data(for: self)

    if let outputFile {
      try data.write(to: outputFile, options: .atomic)
    } else {
      print("\(try data.asUTF8String())")
    }
  }
}
