//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import iTunes

private func changes<Guide: Hashable & Similar, Change: Sendable>(
  configuration: GitTagData.Configuration,
  currentGuides: @Sendable () async throws -> Set<Guide>,
  createGuide: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change?
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagData(configuration: configuration).transformTracks(
    createGuide)

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  return await unknownGuides.changes { createChange($0, currentGuides) }
}

extension Repairable {
  func gather(_ configuration: GitTagData.Configuration, corrections: [String: String])
    async throws -> Patch
  {
    switch self {
    case .artists:
      .artists(
        try await changes(configuration: configuration) {
          try await currentArtists()
        } createGuide: {
          $0.artistNames
        } createChange: {
          guard let valid = $1.correctedSimilarName(to: $0, corrections: corrections) else {
            return nil
          }
          return ($0, valid)
        }.reduce(into: ArtistPatchLookup()) {
          (partialResult: inout ArtistPatchLookup, pair: ArtistPatchLookup.Element) in
          guard partialResult[pair.key] == nil else {
            preconditionFailure("unexpected duplicate name: \(pair.key)")
          }
          partialResult[pair.key] = pair.value
        })
    case .albums:
      .albums(
        try await changes(configuration: configuration) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          guard let valid = $1.correctedSimilarName(to: $0, corrections: corrections) else {
            return nil
          }
          return ($0, valid)
        }.reduce(into: AlbumPatchLookup()) {
          (partialResult: inout AlbumPatchLookup, pair: AlbumPatchLookup.Element) in
          guard partialResult[pair.key] == nil else {
            preconditionFailure("unexpected duplicate name: \(pair.key)")
          }
          partialResult[pair.key] = pair.value
        })
    }
  }
}
