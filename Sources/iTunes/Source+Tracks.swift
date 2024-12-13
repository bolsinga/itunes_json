//
//  Source+Tracks.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Source {
  public func gather(reduce: Bool) async throws -> [Track] {
    try await gather().compactMap { reduce ? $0.reducedTrack : $0 }.map {
      $0.duplicateAndEmptyFieldsRemoved
    }
  }

  private func gather() async throws -> [Track] {
    switch self {
    case .itunes:
      return try Track.gatherAllTracks()
    case .musickit:
      return try await Track.gatherWithMusicKit()
    case .jsonString(let source):
      return try Track.array(from: source)
    }
  }
}
