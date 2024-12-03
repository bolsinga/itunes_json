//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import iTunes

private func changes<Guide: Hashable & Similar, Change: Sendable>(
  configuration: GitTagDataSequence.Configuration,
  currentGuides: @Sendable () async throws -> Set<Guide>,
  createGuide: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change?
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagDataSequence(configuration: configuration).transformTracks(
    createGuide)

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  return await unknownGuides.changes { createChange($0, currentGuides) }
}

extension Repairable {
  func gather(_ configuration: GitTagDataSequence.Configuration, corrections: [String: String])
    async throws -> Patch
  {
    switch self {
    case .artists:
      return .artists(
        try await changes(configuration: configuration) {
          try await currentArtists()
        } createGuide: {
          $0.artistNames
        } createChange: {
          guard let valid = $1.correctedSimilarName(to: $0, corrections: corrections) else {
            return nil
          }
          return ArtistPatch(invalid: $0, valid: valid)
        })
    case .albums:
      return .albums(
        try await changes(configuration: configuration) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          guard let valid = $1.similarName(to: $0) else {
            return nil
          }
          return AlbumPatch(invalid: $0, valid: valid)
        })
    }
  }
}
