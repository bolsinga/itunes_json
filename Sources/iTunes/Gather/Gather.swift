//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation
import os

let mainPrefix = "iTunes"

extension Logger {
  fileprivate static let gather = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "gather")
}

extension Array where Element == Track {
  var artistNames: [SortableName] {
    [SortableName](
      Set(self.filter { $0.isSQLEncodable }.map { $0.artistName(logger: Logger.gather) }))
  }
}

extension URL {
  var itunes: URL { self.appending(path: "itunes.json") }
}

extension SortableName: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(self), let value = String(data: data, encoding: .utf8)
    else { return "" }
    return value
  }
}

private func currentArtists() async throws -> [SortableName] {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.artistNames
}

func gatherUnknownArtists(from gitDirectory: URL) async throws -> [SortableName] {
  let git = Git(directory: gitDirectory, suppressStandardErr: true)

  try git.status()

  async let currentArtists = try await currentArtists()

  var unknownArtists: Set<SortableName> = []

  let tags = try git.tags().matchingFormattedTag(prefix: mainPrefix).sorted()
  for tag in tags {
    Logger.gather.info("tag: \(tag)")
    try git.checkout(commit: tag)

    let artists = Set(try Track.createFromURL(gitDirectory.itunes).artistNames)
    unknownArtists = unknownArtists.union(artists.subtracting(try await currentArtists))
  }
  try git.checkout(commit: "main")

  return Array(unknownArtists)
}

public func gatherUnknownArtists(_ gitDirectory: URL) async throws {
  try await gatherUnknownArtists(from: gitDirectory).sorted().forEach { print($0) }
}
