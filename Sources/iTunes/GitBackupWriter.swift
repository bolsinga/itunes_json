//
//  GitBackupWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

struct GitBackupWriter: DestinationFileWriting {
  let fileWriter: DestinationFileWriting
  let context: BackupContext

  var outputFile: URL { fileWriter.outputFile }

  func write(data: Data) async throws {
    try await gitBackup(file: outputFile, version: context.version) {
      try await context.tag($0)
    } dataWriter: {
      try await fileWriter.write(data: data)
    }
  }
}
