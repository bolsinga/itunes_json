//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Collections
import Foundation

extension IdentityRepair: Identifiable {
  var id: UInt { persistentID }
}

private func currentTracks() async throws -> [Track] {
  try await Source.itunes.gather(reduce: false)
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

private typealias TrackCorrection = @Sendable (Track) -> IdentityRepair.Correction

private func identifierCorrections(
  configuration: GitTagData.Configuration,
  current: @escaping @Sendable () async throws -> [IdentityRepair],
  createCorrection: @escaping TrackCorrection
) async throws -> Patch {
  .identityRepairs(
    Set(
      try await changes(
        configuration: configuration,
        currentGuides: { try await current() },
        createGuide: {
          $0.filter { $0.isSQLEncodable }.map { $0.identityRepair(createCorrection($0)) }
        },
        createChange: {
          (item: IdentityRepair, currentItems: [IdentityRepair]) in
          guard
            let identifierMatch = currentItems.filter({ $0.persistentID == item.persistentID })
              .first
          else { return nil }
          guard item.correction != identifierMatch.correction else { return nil }
          return identifierMatch
        })
    ).sorted())
}

private func identifierCorrections(
  configuration: GitTagData.Configuration,
  createCorrection: @escaping TrackCorrection
) async throws -> Patch {
  try await identifierCorrections(
    configuration: configuration,
    current: { try await currentTracks().map { $0.identityRepair(createCorrection($0)) } },
    createCorrection: createCorrection)
}

private func historicalIdentifierCorrections<Guide: Hashable & Identifiable & Sendable>(
  configuration: GitTagData.Configuration,
  createIdentifier: @escaping @Sendable (_ track: Track) -> Guide,
  relevantChanges: @escaping @Sendable ([Guide.ID: [Guide]]) -> [IdentityRepair]
) async throws -> Patch {
  .identityRepairs(
    Set(
      try await historicalChanges(
        configuration: configuration,
        createGuide: { $0.filter { $0.isSQLEncodable }.map { createIdentifier($0) } },
        relevantChanges: relevantChanges)
    ).sorted())
}

extension IdentityRepair.Correction {
  fileprivate var hasReleaseDate: Bool {
    switch self {
    case .dateReleased(let date):
      return date != nil
    default:
      return false
    }
  }
}

private func identifierLookupCorrections(from string: String) throws -> [UInt: UInt] {
  guard let data = string.data(using: .utf8), !data.isEmpty else { return [:] }
  return try JSONDecoder().decode(Dictionary<UInt, UInt>.self, from: data)
}

private let libraryCorrections: [Repairable: TrackCorrection] = [
  .replaceDurations: { .duration($0.totalTime) },
  .replaceComposers: { .composer($0.composer ?? "") },
  .replaceComments: { .comments($0.comments ?? "") },
  .replaceAlbumTitle: { .albumTitle($0.albumName) },
  .replaceYear: { .year($0.year ?? 0) },
  .replaceTrackNumber: { .trackNumber($0.trackNumber ?? 0) },
  .replaceIdSongTitle: { .replaceSongTitle($0.songName) },
  .replaceIdDiscCount: { .discCount($0.discCount ?? 1) },
  .replaceIdDiscNumber: { .discNumber($0.discNumber ?? 1) },
  .replaceArtist: { .artist($0.artistName) },
]

private enum RepairableError: Error {
  case missingRepairableCorrection
}

extension Repairable {
  func gather(_ configuration: GitTagData.Configuration, correction: String) async throws -> Patch {
    switch self {
    case .replacePersistentIds:
      let lookup = try identifierLookupCorrections(from: correction)
      return try await identifierCorrections(configuration: configuration) {
        lookup.map {
          IdentityRepair(persistentID: $0.key, correction: .persistentID($0.value))
        }
      } createCorrection: {
        .persistentID($0.persistentID)
      }

    case .replaceDateAddeds:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.identityRepair(.dateAdded($0.dateAdded))
      } relevantChanges: {
        // For ids with more than 1 dateAdded correction, use the first correction, since it is sorted by tag.
        $0.filter { $0.value.count > 1 }.compactMap { $0.value.first }
      }

    case .replaceDateReleased:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.identityRepair(.dateReleased($0.releaseDate))
      } relevantChanges: {
        // For ids with more than 1 dateReleased, use the earliest (sorted) correction.
        $0.filter { $0.value.count > 1 }.compactMap {
          $0.value.filter { $0.correction.hasReleaseDate }.sorted().first
        }
      }

    case .replacePlay:
      return try await historicalIdentifierCorrections(configuration: configuration) {
        $0.playIdentity
      } relevantChanges: {
        $0.relevantChanges()
      }

    case .replaceDurations, .replaceComposers, .replaceComments, .replaceAlbumTitle, .replaceYear,
      .replaceTrackNumber, .replaceIdSongTitle, .replaceIdDiscCount, .replaceIdDiscNumber,
      .replaceArtist:
      guard let createCorrection = libraryCorrections[self] else {
        throw RepairableError.missingRepairableCorrection
      }
      return try await identifierCorrections(
        configuration: configuration, createCorrection: createCorrection)
    }
  }
}
