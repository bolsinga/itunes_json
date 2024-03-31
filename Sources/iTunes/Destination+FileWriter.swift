//
//  Destination+FileWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

struct FileWriter: DestinationFileWriting {
  let outputFile: URL

  func write(data: Data) throws {
    try data.write(to: outputFile, options: .atomic)
  }
}
