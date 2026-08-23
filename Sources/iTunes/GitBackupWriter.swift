//
//  GitBackupWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

struct GitBackupWriter: DestinationFileWriting {
  let fileWriter: DestinationFileWriting
  let gitBackupContext: GitBackupContext

  var outputFile: URL { fileWriter.outputFile }

  func write(data: Data) async throws {
    try await gitBackup(file: outputFile, version: gitBackupContext.version) {
      try await gitBackupContext.tag($0)
    } dataWriter: {
      try await fileWriter.write(data: data)
    }
  }
}
