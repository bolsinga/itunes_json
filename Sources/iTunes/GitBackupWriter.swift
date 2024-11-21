//
//  GitBackupWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

extension URL {
  fileprivate var filename: String {
    self.lastPathComponent
  }
}

extension Git {
  fileprivate func validateAndCheckout(branch: String) async throws {
    try await status()
    try await checkout(commit: branch)
  }

  fileprivate func latestTags() async -> [String] {
    guard let latest = try? await tagContains("origin/main").sorted() else { return [] }
    return latest
  }

  fileprivate func addCommitTagPush(filename: String, message: String) async throws {
    try await add(filename)

    let backup = await {
      do {
        try await diff()
        return GitBackup.noChanges
      } catch {
        return GitBackup.changes
      }
    }()

    let backupName = backup.backupName(baseName: message, existingNames: await latestTags())

    switch backup {
    case .noChanges:
      break
    case .changes:
      try await commit(backupName)
    }

    try await tag(backupName)

    try await push()
    try await pushTags()

    try await gc()
  }
}

struct GitBackupWriter: DestinationFileWriting {
  let fileWriter: DestinationFileWriting
  let branch: String
  let tagPrefix: String

  var outputFile: URL { fileWriter.outputFile }

  func write(data: Data) async throws {
    let git = outputFile.parentDirectoryGit

    try await git.validateAndCheckout(branch: branch)
    try await fileWriter.write(data: data)

    try await git.addCommitTagPush(
      filename: outputFile.filename, message: tagPrefix.defaultDestinationName)
  }
}
