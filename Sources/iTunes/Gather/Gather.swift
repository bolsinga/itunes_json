//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import RegexBuilder
import os

let mainPrefix = "iTunes"
let fileName = "itunes.json"

extension Logger {
  fileprivate static let gather = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "gather")
}

extension Array where Element == Track {
  fileprivate var artistNames: [SortableName] {
    [SortableName](
      Set(self.filter { $0.isSQLEncodable }.compactMap { $0.artistName }))
  }
}

extension SortableName {
  fileprivate func isSimilar(to other: SortableName) -> Bool {
    self.name.isSimilar(to: other.name)
  }
}

extension Array where Element == SortableName {
  fileprivate func similarNames(to other: Element) -> [Element] {
    self.filter { $0.isSimilar(to: other) }
  }

  fileprivate func similarName(to other: Element) -> Element? {
    let similarNames = self.similarNames(to: other)
    guard similarNames.count == 1, let similarName = similarNames.first else {
      Logger.gather.log("Candidates (\(similarNames.count)) for \(String(describing: other))")
      return nil
    }
    return similarName
  }

  fileprivate func repairableNames(current other: [Element]) async -> [RepairableName] {
    await withTaskGroup(of: RepairableName.self) { group in
      self.forEach { element in
        group.addTask {
          RepairableName(invalid: element, valid: other.similarName(to: element))
        }
      }
      var repairableNames: [RepairableName] = []
      for await repairableName in group {
        repairableNames.append(repairableName)
      }
      return repairableNames
    }
  }
}

private func currentArtists() async throws -> [SortableName] {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.artistNames
}

private func trackData(from directory: URL, tagPrefix: String) async throws -> [Data] {
  let git = Git(directory: directory, suppressStandardErr: true)

  try await git.status()

  var tagData: [Data] = []

  let tags = try await git.tags().matchingFormattedTag(prefix: tagPrefix).sorted()
  for tag in tags {
    Logger.gather.info("tag: \(tag)")

    tagData.append(try await git.show(commit: tag, path: fileName))
  }

  return tagData
}

private func gatherAllKnownArtists(from gitDirectory: URL) async throws -> Set<SortableName> {
  var tagData = try await trackData(from: gitDirectory, tagPrefix: mainPrefix)

  return try await withThrowingTaskGroup(of: Set<SortableName>.self) { group in
    for data in tagData.reversed() {
      tagData.removeLast()
      group.addTask {
        Set(try Track.createFromData(data).artistNames)
      }
    }

    var allArtistNames: Set<SortableName> = []
    for try await artistNames in group {
      allArtistNames = allArtistNames.union(artistNames)
    }
    return allArtistNames
  }
}

private func gatherRepairableNames(from gitDirectory: URL) async throws -> [RepairableName] {
  async let currentArtists = try await currentArtists()

  let allKnownArtists = try await gatherAllKnownArtists(from: gitDirectory)

  let unknownArtists = Array(allKnownArtists.subtracting(try await currentArtists)).sorted()

  return await unknownArtists.repairableNames(current: try await currentArtists)
}

public func emitRepairableArtistNames(_ gitDirectory: URL) async throws {
  let names = try await gatherRepairableNames(from: gitDirectory)
  print("\(try names.jsonData().asUTF8String())")
}
