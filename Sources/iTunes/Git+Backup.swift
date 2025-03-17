//
//  Git+Backup.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/12/25.
//

import Foundation
import GitLibrary

extension Git {
  private func validateAndCheckout() async throws {
    try await status()
    try await checkout(commit: "main")
  }

  private func addCommitTagPush(filename: String, tagPrefix: String, version: String)
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

  fileprivate func backup(
    _ filename: String, version: String, tagBuilder: (String?) async throws -> String,
    dataWriter: () async throws -> Void
  ) async throws {
    try await validateAndCheckout()
    let tagPrefix = try await tagBuilder(try await describeTag())
    try await dataWriter()

    try await addCommitTagPush(filename: filename, tagPrefix: tagPrefix, version: version)
  }
}

func gitBackup(
  file outputFile: URL, version: String, tagBuilder: (String?) async throws -> String,
  dataWriter: () async throws -> Void
) async throws {
  try await Git(directory: outputFile.parentDirectory).backup(
    outputFile.filename, version: version, tagBuilder: tagBuilder, dataWriter: dataWriter)
}
