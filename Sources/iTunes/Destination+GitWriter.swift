//
//  Destination+GitWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

struct GitWriter: DestinationFileWriting {
  let fileWriter: FileWriter

  func write(data: Data) throws {
    try fileWriter.write(data: data)
    try fileWriter.outputFile.gitAddCommitTagPush(message: String.defaultDestinationName)
  }
}
