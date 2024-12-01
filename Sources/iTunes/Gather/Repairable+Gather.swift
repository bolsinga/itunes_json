//
//  Gather.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/18/24.
//

import Foundation

let mainPrefix = "iTunes"
let fileName = "itunes.json"

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
  fileprivate var artistNames: Set<SortableName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.artistName })
  }

  fileprivate var albumNames: Set<AlbumArtistName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName })
  }
}

extension SortableName: Similar {
  var cullable: Bool {
    sorted.isEmpty
  }

  func isSimilar(to other: SortableName) -> Bool {
    self.name.isSimilar(to: other.name)
  }
}

extension AlbumArtistName: Similar {
  var cullable: Bool {
    true  // FIXME
  }

  func isSimilar(to other: AlbumArtistName) -> Bool {
    // self is the current here.
    self.name.isSimilar(to: other.name) && self.type.isSimilar(to: other.type)
  }
}

private func currentArtists() async throws -> Set<SortableName> {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.artistNames
}

private func currentAlbums() async throws -> Set<AlbumArtistName> {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.albumNames
}

private func changes<Guide: Hashable & Similar, Change: Sendable>(
  from gitDirectory: URL, currentGuides: @Sendable () async throws -> Set<Guide>,
  createGuide: @escaping @Sendable ([Track]) -> Set<Guide>,
  createChange: @escaping @Sendable (Guide, Set<Guide>) -> Change
) async throws -> [Change] {
  async let asyncCurrentGuides = try await currentGuides()

  let allKnownGuides = try await GitTagDataSequence(
    directory: gitDirectory, tagPrefix: mainPrefix, fileName: fileName
  ).transformTracks(createGuide)

  let currentGuides = try await asyncCurrentGuides

  let unknownGuides = Array(allKnownGuides.subtracting(currentGuides))

  return await unknownGuides.changes { createChange($0, currentGuides) }
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
        try await changes(from: gitDirectory) {
          try await currentArtists()
        } createGuide: {
          $0.artistNames
        } createChange: {
          ArtistPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    case .albums:
      return .albums(
        try await changes(from: gitDirectory) {
          try await currentAlbums()
        } createGuide: {
          $0.albumNames
        } createChange: {
          AlbumPatch(invalid: $0, valid: $1.similarName(to: $0))
        })
    }
  }

  public func emit(_ gitDirectory: URL) async throws {
    print(try await self.gather(gitDirectory).jsonString)
  }
}
