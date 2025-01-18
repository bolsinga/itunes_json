//
//  Patchable+Build.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation

extension String {
  fileprivate func replaceTagPrefix(tagPrefix: String) -> String {
    replacePrefix(newPrefix: tagPrefix) ?? "\(self)-Could-Not-Properly-Replace-\(tagPrefix)"
  }
}

extension Tag {
  fileprivate func replace(newTagPrefix: String) -> Tag {
    Tag(tag: tag.replaceTagPrefix(tagPrefix: newTagPrefix), item: item)
  }
}

extension Patch {
  func patch(
    sourceConfiguration: GitTagData.Configuration, patch: Patch, destinationTagPrefix: String,
    destinationConfiguration: GitTagData.Configuration, version: String
  ) async throws {
    let patchedTracksData = try await GitTagData(configuration: sourceConfiguration)
      .transformTracks { try $1.patch(patch, tag: $0) }

    guard let initialCommit = patchedTracksData.initialTag else { return }

    try await GitTagData(configuration: destinationConfiguration).write(
      tagDatum: patchedTracksData.map { $0.replace(newTagPrefix: destinationTagPrefix) },
      initialCommit: initialCommit, version: version)
  }
}
