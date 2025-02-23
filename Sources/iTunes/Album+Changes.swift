//
//  Album+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation

extension Track {
  private var songIdentifier: SongIdentifier? {
    guard let songArtistAlbum else { return nil }
    return SongIdentifier(song: songArtistAlbum, persistentID: persistentID)
  }

  var trackIdentifier: TrackIdentifier? {
    guard let songIdentifier else { return nil }
    return TrackIdentifier(
      songIdentifier: songIdentifier, trackNumber: normalizedTrackNumber, trackCount: trackCount,
      discNumber: albumDiscNumber, discCount: albumDiscCount)
  }
}

extension Array where Element == Track {
  var trackIdentifiers: [TrackIdentifier] {
    [TrackIdentifier](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.trackIdentifier }))
  }
}

func currentTracks() async throws -> [Track] {
  try await Source.itunes.gather(reduce: false)
}

func currentTrackIdentifiers() async throws -> [TrackIdentifier] {
  try await currentTracks().trackIdentifiers
}
