//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import OrderedCollections

private func currentTracks() async throws -> [Track] {
  try await Source.itunes.gather(reduce: false)
}

private func historicalChanges<
  Guide: Hashable & Identifiable & Sendable, Change: Hashable & Sendable
>(
  backupFile: URL,
  createGuide: @escaping @Sendable ([Track]) -> [Guide],
  relevantChanges: @escaping @Sendable ([Guide.ID: [Guide]]) -> [Change]
) async throws -> [Change] {
  // Get all git historical data.
  let allHistoricalGuides = try await backupFile.transformTracks { _, tracks in
    createGuide(tracks)
  }.reduce(into: [Tag<[Guide]>]()) { partialResult, item in
    partialResult.append(item)
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

extension Collection where Element: Hashable & Identifiable {
  fileprivate var lookup: [Element.ID: [Element]] {
    Dictionary(grouping: self) { $0.id }
  }
}

private func changes<Guide: Hashable & Identifiable & Sendable, Change: Sendable>(
  backupFile: URL,
  currentGuides: @Sendable () async throws -> Set<Guide>,
  createGuide: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, [Guide]) -> [Change]
) async throws -> [Change] where Guide.ID: Sendable {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await backupFile.transformTracks { _, tracks in
    createGuide(tracks)
  }.reduce(into: Set<Guide>()) {
    $0.formUnion($1.item)
  }

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  let currentLookup = currentGuides.lookup

  return await unknownGuides.changes { item in
    guard let current = currentLookup[item.id] else { return [] }
    return createChange(item, current)
  }
}

private typealias TrackCorrection = @Sendable (Track) -> [IdentityRepair.Correction]

private func identifierCorrections(
  backupFile: URL,
  current: @escaping @Sendable () async throws -> Set<IdentityRepair>,
  createCorrection: @escaping TrackCorrection
) async throws -> Patch {
  .identityRepairs(
    Set(
      try await changes(
        backupFile: backupFile,
        currentGuides: { try await current() },
        createGuide: {
          Set(
            $0.filter { $0.isSQLEncodable }.flatMap { track in
              createCorrection(track).map { track.identityRepair($0) }
            })
        },
        createChange: { item, currentItems in
          currentItems.filter { $0.isCorrectionValueDifferent(from: item) }
        })
    ).sorted())
}

private func identifierCorrections(backupFile: URL, createCorrection: @escaping TrackCorrection)
  async throws -> Patch
{
  try await identifierCorrections(
    backupFile: backupFile,
    current: {
      Set(
        try await currentTracks().flatMap { track in
          createCorrection(track).map { track.identityRepair($0) }
        })
    },
    createCorrection: createCorrection)
}

private func historicalIdentifierCorrections<Guide: Hashable & Identifiable & Sendable>(
  backupFile: URL,
  createIdentifier: @escaping @Sendable (_ track: Track) -> Guide,
  relevantChanges: @escaping @Sendable ([Guide.ID: [Guide]]) -> [IdentityRepair]
) async throws -> Patch {
  .identityRepairs(
    Set(
      try await historicalChanges(
        backupFile: backupFile,
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

private let libraryCorrections: [Repairable: @Sendable (Track) -> IdentityRepair.Correction] = [
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
  private func gatherLibraryPatch(_ backupFile: URL) async throws -> Patch {
    guard let createCorrection = libraryCorrections[self] else {
      throw RepairableError.missingRepairableCorrection
    }
    return try await identifierCorrections(backupFile: backupFile) { [createCorrection($0)] }
  }

  func gather(_ backupFile: URL, correction: String) async throws -> Patch {
    switch self {
    case .replacePersistentIds:
      let lookup = try identifierLookupCorrections(from: correction)
      return try await identifierCorrections(backupFile: backupFile) {
        Set(
          lookup.map { IdentityRepair(persistentID: $0.key, correction: .persistentID($0.value)) })
      } createCorrection: {
        [.persistentID($0.persistentID)]
      }

    case .replaceDateAddeds:
      return try await historicalIdentifierCorrections(backupFile: backupFile) {
        $0.identityRepair(.dateAdded($0.dateAdded))
      } relevantChanges: {
        // For ids with more than 1 dateAdded correction, use the first correction, since it is sorted by tag.
        $0.filter { $0.value.count > 1 }.compactMap { $0.value.first }
      }

    case .replaceDateReleased:
      return try await historicalIdentifierCorrections(backupFile: backupFile) {
        $0.identityRepair(.dateReleased($0.releaseDate))
      } relevantChanges: {
        // For ids with more than 1 dateReleased, use the earliest (sorted) correction.
        $0.filter { $0.value.count > 1 }.compactMap {
          $0.value.filter { $0.correction.hasReleaseDate }.sorted().first
        }
      }

    case .replacePlay:
      return try await historicalIdentifierCorrections(backupFile: backupFile) {
        $0.playIdentity
      } relevantChanges: {
        $0.relevantChanges()
      }

    case .replaceDurations, .replaceComposers, .replaceComments, .replaceAlbumTitle, .replaceYear,
      .replaceTrackNumber, .replaceIdSongTitle, .replaceIdDiscCount, .replaceIdDiscNumber,
      .replaceArtist:
      return try await gatherLibraryPatch(backupFile)
    }
  }
}
