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

  fileprivate var albumNames: [SortableName] {
    [SortableName](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumName }))
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
    // 'self' contains the current names here.
    var similarNames = self.similarNames(to: other)
    let originalCount = similarNames.count
    var keepLooking = true
    repeat {
      if similarNames.count == 1, let similarName = similarNames.first {
        return similarName
      } else {
        let previousCount = similarNames.count
        similarNames = similarNames.filter { !$0.sorted.isEmpty }
        if similarNames.count == previousCount {
          keepLooking = false
        }
      }
    } while keepLooking

    Logger.gather.log("Candidates (\(originalCount)) for \(String(describing: other))")
    return nil
  }

  fileprivate func repairableNames(currentNames: [Element]) async -> [RepairableName] {
    await withTaskGroup(of: RepairableName.self) { group in
      self.forEach { element in
        group.addTask {
          RepairableName(invalid: element, valid: currentNames.similarName(to: element))
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

private func currentAlbums() async throws -> [SortableName] {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.albumNames
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

private func gatherAllKnownNames(
  from gitDirectory: URL, namer: @escaping @Sendable ([Track]) -> [SortableName]
) async throws -> Set<SortableName> {
  var tagData = try await trackData(from: gitDirectory, tagPrefix: mainPrefix)

  return try await withThrowingTaskGroup(of: Set<SortableName>.self) { group in
    for data in tagData.reversed() {
      tagData.removeLast()
      group.addTask {
        Set(namer(try Track.createFromData(data)))
      }
    }

    var allNames: Set<SortableName> = []
    for try await tracksNames in group {
      allNames = allNames.union(tracksNames)
    }
    return allNames
  }
}

private func gatherRepairableNames(
  from gitDirectory: URL, gatherCurrentNames: @Sendable () async throws -> [SortableName],
  namer: @escaping @Sendable ([Track]) -> [SortableName]
) async throws -> [RepairableName] {
  async let currentNames = try await gatherCurrentNames()

  let allKnownNames = try await gatherAllKnownNames(from: gitDirectory, namer: namer)

  let unknownNames = Array(allKnownNames.subtracting(try await currentNames)).sorted()

  return await unknownNames.repairableNames(currentNames: try await currentNames)
}

extension Repairable {
  func gather(_ gitDirectory: URL) async throws -> [RepairableName] {
    switch self {
    case .artists:
      return try await gatherRepairableNames(from: gitDirectory) {
        try await currentArtists()
      } namer: {
        $0.artistNames
      }
    case .albums:
      return try await gatherRepairableNames(from: gitDirectory) {
        try await currentAlbums()
      } namer: {
        $0.albumNames
      }
    }
  }

  public func emit(_ gitDirectory: URL) async throws {
    print(try await self.gather(gitDirectory).jsonData().asUTF8String())
  }
}
