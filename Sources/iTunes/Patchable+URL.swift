//
//  Patchable+URL.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation

extension Patchable {
  func createPatch(_ fileURL: URL) throws -> Patch {
    switch self {
    case .replaceDurations, .replacePersistentIds, .replaceDateAddeds, .replaceComposers,
      .replaceComments, .replaceDateReleased, .replaceAlbumTitle, .replaceYear,
      .replaceTrackNumber, .replaceIdSongTitle, .replaceIdDiscCount, .replaceIdDiscNumber,
      .replaceArtist, .replacePlay:
      try Patch.load(fileURL)
    }
  }
}
