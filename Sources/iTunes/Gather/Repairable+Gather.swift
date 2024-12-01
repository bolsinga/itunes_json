//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation

let mainPrefix = "iTunes"
let fileName = "itunes.json"

private func changes<Guide: Hashable & Similar, Change: Sendable>(
  from gitDirectory: URL, currentGuides: @Sendable () async throws -> Set<Guide>,
  createGuide: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagDataSequence(
    directory: gitDirectory, tagPrefix: mainPrefix, fileName: fileName
  ).transformTracks(createGuide)

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  return await unknownGuides.changes { createChange($0, currentGuides) }
}

extension Patch {
  var jsonString: String {
    switch self {
    case .artists(let artists):
      return (try? (try? artists.sorted().jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.sorted().jsonData())?.asUTF8String()) ?? ""
    }
  }
}

extension Repairable {
  func gather(_ gitDirectory: URL) async throws -> Patch {
    switch self {
    case .artists:
      return .artists(
        try await changes(from: gitDirectory) {
          try await currentArtists()
        } createGuide: {
          $0.artistNames
        } createChange: {
          ArtistPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    case .albums:
      return .albums(
        try await changes(from: gitDirectory) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          AlbumPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    }
  }

  public func emit(_ gitDirectory: URL) async throws {
    print(try await self.gather(gitDirectory).jsonString)
  }
}
