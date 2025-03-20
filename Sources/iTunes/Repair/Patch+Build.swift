//
//  Patchable+Build.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation

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
  func patch(backupFile: URL, branch: String, version: String) async throws {
    let patchedTracksData = try await backupFile.transformTracks { try $1.patch(self, tag: $0) }

    guard let initialCommit = patchedTracksData.initialTag else { return }

    let tagParser = TagParser()

    try await backupFile.write(
      tagDatum: patchedTracksData.map { try $0.nextVersion(tagParser) },
      initialCommit: initialCommit,
      branch: branch, version: version)
  }
}
