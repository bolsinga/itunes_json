//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation

private func changes<Guide: Hashable & Sendable, Change: Sendable>(
  configuration: GitTagData.Configuration,
  currentGuides: @Sendable () async throws -> [Guide],
  createGuide: @escaping @Sendable ([Track]) -> [Guide],
  createChange: @escaping @Sendable (Guide, [Guide]) -> Change?
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagData(configuration: configuration).transformTracks {
    _, tracks in
    createGuide(tracks)
  }.flatMap { $0.item }

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(Set(allKnownGuides).subtracting(Set(currentGuides)))

  return await unknownGuides.changes { createChange($0, currentGuides) }
}

private func corrections<Guide: Sendable, Change: Sendable>(
  configuration: GitTagData.Configuration,
  currentGuides: @Sendable () async throws -> [Guide],
  brokenGuides: @escaping @Sendable ([Track]) -> [Guide],
  createChange: @escaping @Sendable (Guide, [Guide]) -> Change?
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allBrokenGuides = try await GitTagData(configuration: configuration).transformTracks {
    _, tracks in
    brokenGuides(tracks)
  }.flatMap { $0.item }

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

  fileprivate func songIntCorrections(from string: String) throws -> [SongIntCorrection] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [] }
    return try JSONDecoder().decode(Array<SongIntCorrection>.self, from: data)
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
        Set(
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
          }
        ).sorted()
      )
    case .missingTrackCounts:
      let correction = try albumTrackCounts(from: correction)
      return .trackCounts(
        Set(
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
          }
        ).sorted()
      )
    case .missingTrackNumbers:
      let correction = try songIntCorrections(from: correction)
      return .trackNumbers(
        Set(
          try await corrections(configuration: configuration) {
            try await currentSongTrackNumbers()
          } brokenGuides: {
            $0.filter { $0.isSQLEncodable }.songTrackNumbers.filter { $0.trackNumber == nil }
          } createChange: { item, currentItems in
            if item.trackNumber == nil {
              return Set(currentItems).union(correction).filter { $0.song == item.song }.first
            }
            return nil
          }
        ).sorted()
      )
    case .missingYears:
      let correction = try songIntCorrections(from: correction)
      return .years(
        Set(
          try await corrections(configuration: configuration) {
            try await currentSongYears()
          } brokenGuides: {
            $0.filter { $0.isSQLEncodable }.songYears.filter { $0.year == nil }
          } createChange: { item, currentItems in
            if item.year == nil {
              return Set(currentItems).union(correction).filter { $0.song == item.song }.first
            }
            return nil
          }
        ).sorted()
      )
    case .songs:
      return .songs(
        Set(
          try await corrections(configuration: configuration) {
            try await currentSongIdentifiers()
          } brokenGuides: {
            $0.filter { $0.isSQLEncodable }.songIdentifiers
          } createChange: { (item: SongIdentifier, currentItems: [SongIdentifier]) in
            if let songIdentifier = currentItems.filter({ $0.matchesExcludingSongName(item) })
              .first,
              songIdentifier.song.songArtist.song != item.song.songArtist.song
            {
              return SongTitleCorrection(
                song: item, correctedTitle: songIdentifier.song.songArtist.song)
            }
            return nil
          }
        ).sorted()
      )
    case .replaceTrackCounts:
      return .trackCorrections(
        Set(
          try await changes(configuration: configuration) {
            try await currentTrackIdentifiers()
          } createGuide: {
            $0.filter { $0.isSQLEncodable }.trackIdentifiers
          } createChange: { (item: TrackIdentifier, currentItems: [TrackIdentifier]) in
            guard
              let identifier = currentItems.filter({ $0.matchesExcludingTrackCount(item) }).first
            else { return nil }
            guard let trackCount = identifier.trackCount else { return nil }
            if trackCount != item.trackCount {
              return TrackCorrection(
                songArtistAlbum: identifier.songIdentifier.song, correction: .trackCount(trackCount)
              )
            }
            return nil
          }
        ).sorted()
      )
    }
  }
}
