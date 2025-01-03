//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation

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

private func corrections<Guide: Hashable & Sendable, Change: Sendable>(
  configuration: GitTagData.Configuration,
  currentGuides: @Sendable () async throws -> Set<Guide>,
  brokenGuides: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change?
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allBrokenGuides = try await GitTagData(configuration: configuration).transformTracks(
    brokenGuides)

  let currentGuides = try await asyncCurrentGuides

  return await allBrokenGuides.changes { createChange($0, currentGuides) }
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

  fileprivate func songArtistAlbums(from string: String) throws -> [SongArtistAlbum] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [] }
    return try JSONDecoder().decode(Array<SongArtistAlbum>.self, from: data)
  }

  fileprivate func albumTrackCounts(from string: String) throws -> [AlbumTrackCount] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [] }
    return try JSONDecoder().decode(Array<AlbumTrackCount>.self, from: data)
  }

  fileprivate func songTrackNumbers(from string: String) throws -> [SongTrackNumber] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [] }
    return try JSONDecoder().decode(Array<SongTrackNumber>.self, from: data)
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
    case .missingTitleAlbums:
      let correction = try songArtistAlbums(from: correction)
      return .missingTitleAlbums(
        try await corrections(configuration: configuration) {
          try await currentSongArtistAlbums()
        } brokenGuides: {
          $0.filter { $0.isSQLEncodable }.songArtistAlbums.filter { $0.album == nil }
        } createChange: {
          let similar = $1.similarName(to: $0)
          if similar == nil {
            return correction.similarName(to: $0)
          }
          return similar
        }.reduce(
          into: AlbumMissingTitlePatchLookup(),
          { (partialResult: inout AlbumMissingTitlePatchLookup, item: SongArtistAlbum) in
            guard let album = item.album else { return }
            partialResult[item.songArtist] = album
          }))
    case .trackCounts:
      let correction = try albumTrackCounts(from: correction)
      return .trackCounts(
        try await corrections(configuration: configuration) {
          try await currentAlbumTrackCounts()
        } brokenGuides: {
          $0.filter { $0.isSQLEncodable }.albumTrackCounts.filter { $0.trackCount == nil }
        } createChange: {
          let similar = $1.needsChangeAndSimilar(to: $0)
          if similar == nil {
            return correction.similarName(to: $0)
          }
          return similar
        }.reduce(
          into: AlbumTrackCountLookup(),
          { (partialResult: inout AlbumTrackCountLookup, item: AlbumTrackCount) in
            guard let trackCount = item.trackCount else { return }
            partialResult[item.album] = trackCount
          })
      )
    case .trackNumbers:
      let correction = try songTrackNumbers(from: correction)
      return .trackNumbers(
        try await corrections(configuration: configuration) {
          try await currentSongTrackNumbers()
        } brokenGuides: {
          $0.filter { $0.isSQLEncodable }.songTrackNumbers.filter { $0.trackNumber == nil }
        } createChange: { item, currentItems in
          if item.trackNumber == nil {
            return currentItems.union(correction).filter { $0.song == item.song }.first
          }
          return nil
        }.reduce(
          into: SongTrackNumberLookup(),
          { (partialResult: inout SongTrackNumberLookup, item: SongTrackNumber) in
            guard let trackNumber = item.trackNumber else { return }
            partialResult[item.song] = trackNumber
          }))
    }
  }
}
