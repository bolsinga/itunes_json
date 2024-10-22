//
//  Source+Tracks.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Source {
  public func gather(
    _ source: String?, repair: Repairing?, artistIncluded: ((String) -> Bool)?, reduce: Bool
  )
    async throws -> [Track]
  {
    _repair(tracks: try await gather(source, artistIncluded), repair: repair).compactMap {
      reduce ? $0.reducedTrack : $0
    }.map { $0.duplicateAndEmptyFieldsRemoved }
  }

  private func _repair(tracks: [Track], repair: Repairing?) -> [Track] {
    guard let repair else { return tracks }
    return repair.repair(tracks)
  }

  private func gather(_ source: String?, _ artistIncluded: ((String) -> Bool)?) async throws
    -> [Track]
  {
    let tracks = try await _gather(source)
    if let artistIncluded {
      return tracks.filter {
        if let artist = $0.artist {
          return artistIncluded(artist)
        }
        return false
      }
    }
    return tracks
  }

  private func _gather(_ source: String?) async throws -> [Track] {
    switch self {
    case .itunes:
      return try Track.gatherAllTracks()
    case .musickit:
      return try await Track.gatherWithMusicKit()
    case .jsonString:
      return try Track.createFromString(source)
    }
  }
}
