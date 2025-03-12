//
//  GitBackupWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation
import GitLibrary

extension URL {
  fileprivate var filename: String {
    self.lastPathComponent
  }

  fileprivate var parentDirectory: URL {
    self.deletingLastPathComponent()
  }
}

extension Git {
  fileprivate func validateAndCheckout() async throws {
    try await status()
    try await checkout(commit: "main")
  }

  fileprivate func addCommitTagPush(filename: String, tagPrefix: String, version: String)
    async throws
  {
    let message = tagPrefix.defaultDestinationName

    try await add(filename)

    let backup = await {
      do {
        try await diff()
        return Backup.noChanges
      } catch {
        return Backup.changes
      }
    }()

    let backupName = backup.backupName(
      baseName: message, existingNames: tagPrefix.allMatchingTags(try? await tags()))

    switch backup {
    case .noChanges:
      break
    case .changes:
      try await commit("\(backupName)\n\(version)")
    }

    try await tag(backupName)

    try await push()
    try await pushTags()

    try await gc()
  }
}

struct GitBackupWriter: DestinationFileWriting {
  let fileWriter: DestinationFileWriting
  let context: BackupContext

  var outputFile: URL { fileWriter.outputFile }

  func write(data: Data) async throws {
    let git = Git(directory: outputFile.parentDirectory)

    try await git.validateAndCheckout()
    let tagPrefix = try await context.tag(try await git.describeTag())
    try await fileWriter.write(data: data)

    try await git.addCommitTagPush(
      filename: outputFile.filename, tagPrefix: tagPrefix, version: context.version)
  }
}
