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

extension Track {
  private var isCompilation: Bool {
    guard let compilation else { return false }
    return compilation
  }

  private var albumType: AlbumArtistName.AlbumType {
    if isCompilation {
      return .compilation
    } else if let artistName = artistName {
      return .artist(artistName.name)
    } else {
      return .unknown
    }
  }

  var albumArtistName: AlbumArtistName? {
    guard let albumName else { return nil }
    return AlbumArtistName(name: albumName, type: albumType)
  }
}

extension Array where Element == Track {
  fileprivate var artistNames: [SortableName] {
    [SortableName](
      Set(self.filter { $0.isSQLEncodable }.compactMap { $0.artistName }))
  }

  fileprivate var albumNames: [AlbumArtistName] {
    [AlbumArtistName](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName }))
  }
}

private protocol Similar: Sendable {
  func isSimilar(to other: Self) -> Bool
  var cullable: Bool { get }
}

extension SortableName: Similar {
  fileprivate var cullable: Bool {
    sorted.isEmpty
  }

  fileprivate func isSimilar(to other: SortableName) -> Bool {
    self.name.isSimilar(to: other.name)
  }
}

extension AlbumArtistName: Similar {
  fileprivate var cullable: Bool {
    true  // FIXME
  }

  fileprivate func isSimilar(to other: AlbumArtistName) -> Bool {
    // self is the current here.
    self.name.isSimilar(to: other.name) && self.type.isSimilar(to: other.type)
  }
}

extension Array where Element: Similar {
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
        similarNames = similarNames.filter { !$0.cullable }
        if similarNames.count == previousCount {
          keepLooking = false
        }
      }
    } while keepLooking

    Logger.gather.log("Candidates (\(originalCount)) for \(String(describing: other))")
    return nil
  }

  fileprivate func mendables<T: Sendable>(mend: @escaping @Sendable (Element) -> T) async -> [T] {
    await withTaskGroup(of: T.self) { group in
      self.forEach { element in
        group.addTask { mend(element) }
      }
      var mendables: [T] = []
      for await mendable in group {
        mendables.append(mendable)
      }
      return mendables
    }
  }
}

private func currentArtists() async throws -> [SortableName] {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.artistNames
}

private func currentAlbums() async throws -> [AlbumArtistName] {
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

private func gatherAllKnown<Name: Hashable & Sendable>(
  from gitDirectory: URL, namer: @escaping @Sendable ([Track]) -> [Name]
) async throws -> Set<Name> {
  var tagData = try await trackData(from: gitDirectory, tagPrefix: mainPrefix)

  return try await withThrowingTaskGroup(of: Set<Name>.self) { group in
    for data in tagData.reversed() {
      tagData.removeLast()
      group.addTask {
        Set(namer(try Track.createFromData(data)))
      }
    }

    var allNames: Set<Name> = []
    for try await tracksNames in group {
      allNames = allNames.union(tracksNames)
    }
    return allNames
  }
}

private func gatherRepairable<Name: Hashable & Similar, Mendable: Sendable>(
  from gitDirectory: URL, gatherCurrentNames: @Sendable () async throws -> [Name],
  namer: @escaping @Sendable ([Track]) -> [Name],
  mend: @escaping @Sendable (Name, [Name]) -> Mendable
) async throws -> [Mendable] {
  async let asyncCurrentNames = try await gatherCurrentNames()

  let allKnownNames = try await gatherAllKnown(from: gitDirectory, namer: namer)

  let currentNames = try await asyncCurrentNames

  let unknownNames = Array(allKnownNames.subtracting(currentNames))

  return await unknownNames.mendables { mend($0, currentNames) }
}

extension Patch {
  var jsonString: String {
    switch self {
    case .artists(let artists):
      return (try? (try? artists.sorted().jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.sorted().jsonData())?.asUTF8String()) ?? ""
    }
  }
}

extension Repairable {
  func gather(_ gitDirectory: URL) async throws -> Patch {
    switch self {
    case .artists:
      return .artists(
        try await gatherRepairable(from: gitDirectory) {
          try await currentArtists()
        } namer: {
          $0.artistNames
        } mend: {
          ArtistPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    case .albums:
      return .albums(
        try await gatherRepairable(from: gitDirectory) {
          try await currentAlbums()
        } namer: {
          $0.albumNames
        } mend: {
          AlbumPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    }
  }

  public func emit(_ gitDirectory: URL) async throws {
    print(try await self.gather(gitDirectory).jsonString)
  }
}
