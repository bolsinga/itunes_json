//
//  Source+Tracks.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Source {
  func gather(reduce: Bool) async throws -> [Track] {
    try await gather().compactMap { reduce ? $0.reducedTrack : $0 }.map {
      $0.duplicateAndEmptyFieldsRemoved
    }
  }

  private func gather() async throws -> [Track] {
    switch self {
    case .itunes:
      #if canImport(iTunesLibrary)
        return try Track.gatherAllTracks()
      #else
        enum iTunesError: Error {
          case notAvailable
        }
        throw iTunesError.notAvailable
      #endif
    case .musickit:
      return try await Track.gatherWithMusicKit()
    }
  }
}
