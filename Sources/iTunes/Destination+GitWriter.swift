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
  func validate() throws {
    try status()
    try checkoutMain()
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
  let fileWriter: FileWriter

  func write(data: Data) throws {
    let git = fileWriter.outputFile.parentDirectoryGit

    try git.validate()
    try fileWriter.write(data: data)

    try git.addCommitTagPush(
      filename: fileWriter.outputFile.filename, message: String.defaultDestinationName)
  }
}
