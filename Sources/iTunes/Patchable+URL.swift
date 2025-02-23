//
//  Patchable+URL.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation

extension Array where Element: Codable {
  static fileprivate func load(from url: URL) throws -> Self {
    try load(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static fileprivate func load(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Self.self, from: data)
  }
}

extension Patchable {
  func createPatch(_ fileURL: URL) throws -> Patch {
    switch self {
    case .replaceDurations, .replacePersistentIds, .replaceDateAddeds, .replaceComposers,
      .replaceComments, .replaceDateReleased, .replaceAlbumTitle, .replaceYear,
      .replaceTrackNumber, .replaceIdSongTitle, .replaceIdDiscCount, .replaceIdDiscNumber,
      .replaceArtist, .replacePlay:
      try Self.identifierCorrections(fileURL)
    }
  }

  static func identifierCorrections(_ fileURL: URL) throws -> Patch {
    Patch.identifierCorrections(try Array<IdentifierCorrection>.load(from: fileURL))
  }
}
