//
//  URL+Write+TagData.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/17/25.
//

import Foundation
import GitLibrary
import os

extension Logger {
  fileprivate static let writeTagData = Logger(category: "writeTagData")
}

extension Git {
  fileprivate func addAndTag(fileName: String, tag tagName: String, version: String) async throws {
    try await add(fileName)

    let hasChanges = await {
      do {
        try await diff()
        Logger.writeTagData.info("Empty Tag: \(tagName)")
        return false
      } catch {
        return true
      }
    }()

    if hasChanges {
      try await commit("\(tagName)\n\(version)")
    }
    try await tag(tagName)
  }
}

extension Tag where Item == Data {
  fileprivate func add(to git: Git, backupFile: URL, version: String) async throws {
    Logger.writeTagData.info("Add: \(tag)")

    // this makes memory shoot up, unexpectedly.
    try item.write(to: backupFile)

    try await git.addAndTag(fileName: backupFile.lastPathComponent, tag: tag, version: version)
  }
}

extension URL {
  func write(tagDatum: [Tag<Data>], initialCommit: String, branch: String, version: String)
    async throws
  {
    let git = Git(directory: self.parentDirectory, suppressStandardErr: true)

    try await git.status()

    try await git.createBranch(named: branch, initialCommit: initialCommit)

    var tagDatum = tagDatum.sorted(by: { $0.tag > $1.tag })  // latest to oldest.

    for tagData in tagDatum.reversed() {
      tagDatum.removeLast()

      try await tagData.add(to: git, backupFile: self, version: version)
    }

    //    try await git.push()
    //    try await git.pushTags()
    //    try await git.gc()
  }
}
