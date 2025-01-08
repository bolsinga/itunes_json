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
}

extension Git {
  fileprivate func validateAndCheckout(branch: String) async throws {
    try await status()
    try await checkout(commit: branch)
  }

  fileprivate func latestTags(matching tagPrefix: String) async -> [String] {
    guard let allTags = try? await tags() else { return [] }

    let latest = allTags.filter {
      guard let prefix = $0.tagPrefix else {
        return false
      }
      return prefix.starts(with: tagPrefix)
    }.sorted()
    return latest
  }

  fileprivate func addCommitTagPush(filename: String, tagPrefix: String, version: String)
    async throws
  {
    let message = tagPrefix.defaultDestinationName

    try await add(filename)

    let backup = await {
      do {
        try await diff()
        return GitBackup.noChanges
      } catch {
        return GitBackup.changes
      }
    }()

    let backupName = backup.backupName(
      baseName: message, existingNames: await latestTags(matching: tagPrefix))

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
    let git = outputFile.parentDirectoryGit

    try await git.validateAndCheckout(branch: context.branch)
    let tagPrefix = try await context.tag(git)
    try await fileWriter.write(data: data)

    try await git.addCommitTagPush(
      filename: outputFile.filename, tagPrefix: tagPrefix, version: context.version)
  }
}
