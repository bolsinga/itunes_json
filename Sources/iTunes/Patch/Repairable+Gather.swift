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
  private var isLibraryRepair: Bool {
    switch self {
    case .replaceDurations, .replaceComposers, .replaceComments, .replaceAlbumTitle, .replaceYear,
      .replaceTrackNumber, .replaceIdSongTitle, .replaceIdDiscCount, .replaceIdDiscNumber,
      .replaceArtist:
      return true

    case .replaceDateAddeds, .replaceDateReleased, .replacePlay:
      return false

    case .replacePersistentIds, .libraryRepairs, .historyRepairs, .allRepairs:
      return false
    }
  }

  static var libraryRepairable: [Repairable] {
    Self.allCases.filter { $0.isLibraryRepair }
  }
}

extension Patch {
  func merge(_ other: Patch) -> Patch {
    .identityRepairs(Array(Set(self.identityRepairs).union(Set(other.identityRepairs))))
  }

  func sorted() -> Patch {
    .identityRepairs(self.identityRepairs.sorted())
  }
}

extension Repairable {
  private func gatherLibraryPatch(_ backupFile: URL) async throws -> Patch {
    guard let createCorrection = libraryCorrections[self] else {
      throw RepairableError.missingRepairableCorrection
    }
    return try await identifierCorrections(backupFile: backupFile) { [createCorrection($0)] }
  }

  /// The Library is the Source of truth. This is where the data can be corrected in Music.app. Duration is a tricky one, in that Music.app is the source of truth, but its value changes at indeterminate moments.
  private static func gatherLibraryPatches(_ backupFile: URL) async throws -> Patch {
    try await identifierCorrections(
      backupFile: backupFile,
      createCorrection: { track in
        Self.libraryRepairable.compactMap {
          guard let createCorrection = libraryCorrections[$0] else { return nil }
          return createCorrection(track)
        }
      })
  }

  /// History is the Source of truth. This is simple data, such as date added, date released. It's more complex, but date played and play count is also historically true. This is all data that is not modifiable in Music.app.
  /// These are done with async let, which means the backupFile versions are iterated for each. It's hard to re-use (as done for Library patches) since there are two Guide types, and finding relevant changes depends upon the Guide.
  private static func gatherHistoryPatches(_ backupFile: URL) async throws -> Patch {
    async let dateAddedPatch = Repairable.replaceDateAddeds.gather(backupFile)
    async let dateReleasedPatch = Repairable.replaceDateReleased.gather(backupFile)
    // .replacePlay is still experimental.
    return try await dateAddedPatch.merge(try await dateReleasedPatch).sorted()
  }

  private static func gatherAllPatches(_ backupFile: URL) async throws -> Patch {
    async let libraryChanges = try await gatherLibraryPatches(backupFile)
    async let historyChanges = try await gatherHistoryPatches(backupFile)

    return try await libraryChanges.merge(try await historyChanges).sorted()
  }

  func gather(_ backupFile: URL, correction: String = "") async throws -> Patch {
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

    case .libraryRepairs:
      return try await Self.gatherLibraryPatches(backupFile)

    case .historyRepairs:
      return try await Self.gatherHistoryPatches(backupFile)

    case .allRepairs:
      return try await Self.gatherAllPatches(backupFile)
    }
  }
}
