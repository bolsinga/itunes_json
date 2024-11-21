//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
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

private func gatherUnknownArtists(from gitDirectory: URL) async throws -> [SortableName] {
  async let currentArtists = try await currentArtists()

  let allKnownArtists = try await gatherAllKnownArtists(from: gitDirectory)

  return Array(allKnownArtists.subtracting(try await currentArtists))
}

public func gatherUnknownArtists(_ gitDirectory: URL) async throws {
  let data = try await gatherUnknownArtists(from: gitDirectory).sorted().jsonData()
  print("\(try data.asUTF8String())")
}
