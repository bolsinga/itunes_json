//
//  GitTagData.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import GitLibrary

struct GitTagData {
  let backupFile: URL
  private let git: Git

  init(backupFile: URL) throws {
    self.backupFile = backupFile
    self.git = Git(directory: backupFile.parentDirectory, suppressStandardErr: true)
  }

  func tagDatum() async throws -> [Tag<Data>] {
    try await self.git.status()

    var tagDatum: [Tag<Data>] = []
    for try await tagData in TagSequence(
      tags: try await git.tags().stampOrderedMatching,
      dataProvider: {
        try await git.show(commit: $0, path: backupFile.filename)
      })
    {
      tagDatum.append(tagData)

    }
    return tagDatum
  }
}
