//
//  Patchable+Build.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation
import iTunes

extension Patch {
  func patch(
    sourceConfiguration: GitTagData.Configuration, patch: Patch, tagAppendix: String,
    destinationConfiguration: GitTagData.Configuration
  ) async throws {
    let patchedTracksData = try await GitTagData(configuration: sourceConfiguration)
      .transformTaggedTracks { try $1.patch(patch, tag: $0) }

    guard let initialCommit = patchedTracksData.initialCommit else { return }

    try await GitTagData(configuration: destinationConfiguration).write(
      tagDatum: patchedTracksData.addTagAppendix(tagAppendix: tagAppendix),
      initialCommit: initialCommit)
  }
}
