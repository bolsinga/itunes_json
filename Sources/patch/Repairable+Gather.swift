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
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagDataSequence(configuration: configuration).transformTracks(
    createGuide)

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  return await unknownGuides.changes { createChange($0, currentGuides) }
}

extension Patch {
  fileprivate var jsonString: String {
    switch self {
    case .artists(let artists):
      return (try? (try? artists.sorted().jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.sorted().jsonData())?.asUTF8String()) ?? ""
    }
  }
}

extension Repairable {
  fileprivate func gather(_ configuration: GitTagDataSequence.Configuration) async throws -> Patch {
    switch self {
    case .artists:
      return .artists(
        try await changes(configuration: configuration) {
          try await currentArtists()
        } createGuide: {
          $0.artistNames
        } createChange: {
          ArtistPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    case .albums:
      return .albums(
        try await changes(configuration: configuration) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          AlbumPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    }
  }

  public func emit(_ configuration: GitTagDataSequence.Configuration) async throws {
    print(try await self.gather(configuration).jsonString)
  }
}
