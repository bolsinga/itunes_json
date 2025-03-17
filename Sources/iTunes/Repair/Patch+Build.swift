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
  fileprivate func nextVersion() throws -> Tag {
    guard let structuredTag = tag.structuredTag else { throw TagError.unstructuredTag }
    return Tag(tag: structuredTag.next.description, item: item)
  }
}

extension Patch {
  func patch(
    sourceConfiguration: GitTagData.Configuration,
    destinationConfiguration: GitTagData.Configuration, branch: String, version: String
  ) async throws {
    let patchedTracksData = try await GitTagData(configuration: sourceConfiguration)
      .transformTracks { try $1.patch(self, tag: $0) }

    guard let initialCommit = patchedTracksData.initialTag else { return }

    try await GitTagData(configuration: destinationConfiguration).write(
      tagDatum: patchedTracksData.map { try $0.nextVersion() },
      initialCommit: initialCommit, branch: branch, version: version)
  }
}
