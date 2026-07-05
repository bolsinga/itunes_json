//
//  Patchable+Build.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation
import GitLibrary

private enum TagError: Error {
  case unstructuredTag
}

extension Tag {
  fileprivate func nextVersion(_ tagParser: TagParser) throws -> Tag {
    guard let structuredTag = tagParser.structuredTag(tag) else { throw TagError.unstructuredTag }
    return Tag(tag: structuredTag.next.description, item: item)
  }
}

extension Patch {
  func patch(
    backupFile: URL,
    branch: String,
    version: String
  ) async throws {
    let git = Implementation.outOfProcess(
      directory: backupFile.parentDirectory, suppressStandardErr: true
    ).create()

    let patchedTracksData = try await git.transformTracks(filename: backupFile.filename) {
      try $1.patch(self, tag: $0)
    }
    .reduce(into: [Tag<Data>]()) { $0.append($1) }

    guard let initialCommit = patchedTracksData.initialTag else { return }

    let tagParser = TagParser()

    try await backupFile.write(
      tagDatum: patchedTracksData.map { try $0.nextVersion(tagParser) },
      initialCommit: initialCommit,
      branch: branch,
      version: version)
  }
}
