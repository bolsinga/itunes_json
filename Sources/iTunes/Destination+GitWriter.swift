//
//  Destination+GitWriter.swift
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
  func validateAndCheckout(branch: String) throws {
    try status()
    try checkout(branch: branch)
  }

  fileprivate var latestTags: [String] {
    guard let latest = try? tagContains("origin/main").sorted() else { return [] }
    return latest
  }

  func addCommitTagPush(filename: String, message: String) throws {
    try add(filename)

    let backup = {
      do {
        try diff()
        return GitBackup.noChanges
      } catch {
        return GitBackup.changes
      }
    }()

    let backupName = backup.backupName(baseName: message, existingNames: latestTags)

    switch backup {
    case .noChanges:
      break
    case .changes:
      try commit(backupName)
    }

    try tag(backupName)

    try push()
    try pushTags()

    try gc()
  }
}

struct GitWriter: DestinationFileWriting {
  let fileWriter: DestinationFileWriting
  let branch: String
  let tagPrefix: String

  var outputFile: URL { fileWriter.outputFile }

  func write(data: Data) throws {
    let git = outputFile.parentDirectoryGit

    try git.validateAndCheckout(branch: branch)
    try fileWriter.write(data: data)

    try git.addCommitTagPush(
      filename: outputFile.filename, message: tagPrefix.defaultDestinationName)
  }
}
