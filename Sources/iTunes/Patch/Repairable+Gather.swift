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

private func trackCorrections(
  configuration: GitTagData.Configuration,
  createCorrection: @escaping @Sendable (_ item: TrackIdentifier, _ identifier: TrackIdentifier) ->
    TrackCorrection.Property?
) async throws -> Patch {
  .trackCorrections(
    Set(
      try await changes(
        configuration: configuration,
        currentGuides: { try await currentTrackIdentifiers() },
        createGuide: { $0.filter { $0.isSQLEncodable }.trackIdentifiers },
        createChange: {
          (item: TrackIdentifier, currentItems: [TrackIdentifier]) in
          guard let identifier = currentItems.filter({ $0.matchesSongIdentifier(item) }).first
          else { return nil }
          guard let property = createCorrection(item, identifier) else { return nil }
          return TrackCorrection(
            songArtistAlbum: identifier.songIdentifier.song, correction: property)
        })
    ).sorted())
}

private func identifierCorrections(
  configuration: GitTagData.Configuration,
  current: @escaping @Sendable () async throws -> [IdentifierCorrection],
  createIdentifier: @escaping @Sendable (_ track: Track) -> IdentifierCorrection,
  qualifies: @escaping @Sendable (_ item: IdentifierCorrection, _ current: IdentifierCorrection) ->
    Bool
) async throws -> Patch {
  .identifierCorrections(
    Set(
      try await changes(
        configuration: configuration,
        currentGuides: { try await current() },
        createGuide: {
          $0.filter { $0.isSQLEncodable }.map { createIdentifier($0) }
        },
        createChange: {
          (item: IdentifierCorrection, currentItems: [IdentifierCorrection]) in
          guard
            let identifierMatch = currentItems.filter({ $0.persistentID == item.persistentID })
              .first
          else { return nil }
          guard qualifies(item, identifierMatch) else { return nil }
          return identifierMatch
        })
    ).sorted())
}

private func identifierCorrections(
  configuration: GitTagData.Configuration,
  createIdentifier: @escaping @Sendable (_ track: Track) -> IdentifierCorrection,
  qualifies: @escaping @Sendable (_ item: IdentifierCorrection, _ current: IdentifierCorrection) ->
    Bool
) async throws -> Patch {
  try await identifierCorrections(
    configuration: configuration,
    current: { try await currentTracks().map { createIdentifier($0) } },
    createIdentifier: createIdentifier, qualifies: qualifies)
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

  fileprivate func identifierLookupCorrections(from string: String) throws -> [UInt: UInt] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [:] }
    return try JSONDecoder().decode(Dictionary<UInt, UInt>.self, from: data)
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
      return try await trackCorrections(configuration: configuration) {
        (item: TrackIdentifier, identifier: TrackIdentifier) in
        guard let trackCount = identifier.trackCount else { return nil }
        guard trackCount != item.trackCount else { return nil }

        return .trackCount(trackCount)
      }
    case .replaceDiscCounts:
      return try await trackCorrections(configuration: configuration) {
        (item: TrackIdentifier, identifier: TrackIdentifier) in
        guard let discCount = identifier.discCount else { return nil }
        guard discCount != item.discCount else { return nil }

        return .discCount(discCount)
      }
    case .replaceDiscNumbers:
      return try await trackCorrections(configuration: configuration) {
        (item: TrackIdentifier, identifier: TrackIdentifier) in
        guard let discNumber = identifier.discNumber else { return nil }
        guard discNumber != item.discNumber else { return nil }

        return .discNumber(discNumber)
      }

    case .replaceDurations:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.duration(track.totalTime))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.duration(let itemValue), .duration(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replacePersistentIds:
      let lookup = try identifierLookupCorrections(from: correction)
      return try await identifierCorrections(configuration: configuration) {
        lookup.map {
          IdentifierCorrection(persistentID: $0.key, correction: .persistentID($0.value))
        }
      } createIdentifier: { track in
        track.identifierCorrection(.duration(track.totalTime))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.persistentID(let itemValue), .persistentID(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceDateAddeds:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.dateAdded(track.dateAdded))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.dateAdded(let itemValue), .dateAdded(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    }
  }
}
