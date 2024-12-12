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
  enum CorrectionError: Error {
    case noData
  }

  private func data(from string: String) throws -> Data {
    guard let data = string.data(using: .utf8) else {
      throw CorrectionError.noData
    }
    return data
  }

  private func correctionLookup(from string: String) throws -> [String: String] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [:] }
    return try JSONDecoder().decode(Dictionary<String, String>.self, from: data)
  }

  fileprivate func artistCorrections(from string: String) throws -> [String: String] {
    try correctionLookup(from: string)
  }

  fileprivate func albumCorrection(from string: String) throws -> AlbumCorrection {
    let data = try data(from: string)
    guard !data.isEmpty else { return AlbumCorrection() }
    return try JSONDecoder().decode(AlbumCorrection.self, from: data)
  }
}

extension Repairable {
  func gather(_ configuration: GitTagData.Configuration, correction: String) async throws -> Patch {
    switch self {
    case .artists:
      let corrections = try artistCorrections(from: correction)
      return .artists(
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
      let correction = try albumCorrection(from: correction)
      return .albums(
        try await changes(configuration: configuration) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          guard let valid = $1.correctedSimilarName(to: $0, correction: correction) else {
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
