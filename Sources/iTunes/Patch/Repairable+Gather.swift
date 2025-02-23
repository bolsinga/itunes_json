//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Collections
import Foundation

extension IdentifierCorrection: Identifiable {
  var id: UInt { persistentID }
}

private func historicalChanges<
  Guide: Hashable & Identifiable & Sendable, Change: Hashable & Sendable
>(
  configuration: GitTagData.Configuration,
  createGuide: @escaping @Sendable ([Track]) -> [Guide],
  relevantChanges: @escaping @Sendable ([Guide.ID: [Guide]]) -> [Change]
) async throws -> [Change] {
  // Get all git historical data.
  let allHistoricalGuides = try await GitTagData(configuration: configuration).transformTracks {
    _, tracks in
    createGuide(tracks)
  }

  // sort data by tag ascending (oldest to newest).
  let allHistoricalGuidesSorted = allHistoricalGuides.sorted(by: { $0.tag < $1.tag }).map {
    $0.item
  }

  // Create a [HistoricalID: OrderedSet<Guide>]. This will get all unique Guides in tag order. Then covert it into [HistoricalID: [Guide]].
  let historicalLookup = allHistoricalGuidesSorted.reduce(into: [Guide.ID: OrderedSet<Guide>]()) {
    (partialResult: inout [Guide.ID: OrderedSet<Guide>], item: [Guide]) in
    partialResult = item.reduce(into: partialResult) {
      (partialResult: inout [Guide.ID: OrderedSet<Guide>], item: Guide) in
      let id = item.id
      var results = partialResult[id] ?? []
      results.append(item)
      partialResult[id] = results
    }
  }.mapValues { Array($0) }

  // Get the relevant changes, according to the caller.
  return Array(Set(relevantChanges(historicalLookup)))
}

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

private func identifierCorrections(
  configuration: GitTagData.Configuration,
  additionalIdentifiers: [IdentifierCorrection] = [],
  createIdentifier: @escaping @Sendable (_ track: Track) -> IdentifierCorrection,
  qualifies: @escaping @Sendable (_ item: IdentifierCorrection, _ current: IdentifierCorrection) ->
    Bool
) async throws -> Patch {
  try await identifierCorrections(
    configuration: configuration,
    current: { try await currentTracks().map { createIdentifier($0) } + additionalIdentifiers },
    createIdentifier: createIdentifier, qualifies: qualifies
  ).addIdentifierCorrections(additionalIdentifiers)
}

private func historicalIdentifierCorrections<Guide: Hashable & Identifiable & Sendable>(
  configuration: GitTagData.Configuration,
  createIdentifier: @escaping @Sendable (_ track: Track) -> Guide?,
  relevantChanges: @escaping @Sendable ([Guide.ID: [Guide]]) -> [IdentifierCorrection]
) async throws -> Patch {
  .identifierCorrections(
    Set(
      try await historicalChanges(
        configuration: configuration,
        createGuide: { $0.filter { $0.isSQLEncodable }.compactMap { createIdentifier($0) } },
        relevantChanges: relevantChanges)
    ).sorted())
}

extension IdentifierCorrection.Property {
  fileprivate var hasReleaseDate: Bool {
    switch self {
    case .dateReleased(let date):
      return date != nil
    default:
      return false
    }
  }
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

  fileprivate func identifierStringLookupCorrections(from string: String) throws -> [UInt: String] {
    let data = try data(from: string)
    guard !data.isEmpty else { return [:] }
    return try JSONDecoder().decode(Dictionary<UInt, String>.self, from: data)
  }
}

extension Repairable {
  func gather(_ configuration: GitTagData.Configuration, correction: String) async throws -> Patch {
    switch self {
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
        track.identifierCorrection(.persistentID(track.persistentID))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.persistentID(let itemValue), .persistentID(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceDateAddeds:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.identifierCorrection(.dateAdded($0.dateAdded))
      } relevantChanges: {
        // For ids with more than 1 dateAdded correction, use the first correction, since it is sorted by tag.
        $0.filter { $0.value.count > 1 }.compactMap { $0.value.first }
      }

    case .replaceComposers:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.composer(track.composer ?? ""))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.composer(let itemValue), .composer(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceComments:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.comments(track.comments ?? ""))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.comments(let itemValue), .comments(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceDateReleased:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.identifierCorrection(.dateReleased($0.releaseDate))
      } relevantChanges: {
        // For ids with more than 1 dateReleased, use the earliest (sorted) correction.
        $0.filter { $0.value.count > 1 }.compactMap {
          $0.value.filter { $0.correction.hasReleaseDate }.sorted().first
        }
      }

    case .replaceAlbumTitle:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.albumTitle(track.albumName))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.albumTitle(let itemValue), .albumTitle(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceSongTitle:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.songTitle(track.songName))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.songTitle(let itemValue), .songTitle(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceYear:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.year(track.year ?? 0))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.year(let itemValue), .year(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceTrackNumber:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.trackNumber(track.trackNumber ?? 0))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.trackNumber(let itemValue), .trackNumber(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceIdSongTitle:
      let additionalIdentifiers = try identifierStringLookupCorrections(from: correction).map {
        IdentifierCorrection(
          persistentID: $0.key, correction: .replaceSongTitle(SortableName(name: $0.value)))
      }
      return try await identifierCorrections(
        configuration: configuration, additionalIdentifiers: additionalIdentifiers
      ) { track in
        track.identifierCorrection(.songTitle(track.songName))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.replaceSongTitle(_), .replaceSongTitle(_)):
          return true
        default:
          return false
        }
      }

    case .replaceIdDiscCount:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.discCount(track.discCount ?? 1))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.discCount(let itemValue), .discCount(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceIdDiscNumber:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.discNumber(track.discNumber ?? 1))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.discNumber(let itemValue), .discNumber(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replaceArtist:
      return try await identifierCorrections(configuration: configuration) { track in
        track.identifierCorrection(.artist(track.artistName))
      } qualifies: { item, current in
        switch (item.correction, current.correction) {
        case (.artist(let itemValue), .artist(let currentValue)):
          return itemValue != currentValue
        default:
          return false
        }
      }

    case .replacePlay:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.playIdentity
      } relevantChanges: {
        $0.relevantChanges()
      }
    }
  }
}
