//
//  Source+Tracks.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Source {
  public func gather(_ source: String?, repair: Repairing?) async throws -> [Track] {
    let tracks = try await gather(source)
    return repair != nil ? repair!.repair(tracks) : tracks
  }

  private func gather(_ source: String?) async throws -> [Track] {
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
