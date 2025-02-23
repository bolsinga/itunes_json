//
//  Album+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation

typealias SongTrackNumber = SongIntCorrection

extension SongTrackNumber {
  init(song: SongArtistAlbum, trackNumber: Int?) {
    self.init(song: song, value: trackNumber)
  }

  var trackNumber: Int? { value }
}

extension Track {
  private var isCompilation: Bool {
    guard let compilation else { return false }
    return compilation
  }

  private var albumType: AlbumArtistName.AlbumType {
    if isCompilation {
      .compilation(artist)
    } else if let artistName = artistName {
      .artist(artistName.name)
    } else {
      .unknown
    }
  }

  var albumArtistName: AlbumArtistName? {
    guard let albumName else { return nil }
    return AlbumArtistName(name: albumName, type: albumType)
  }

  var albumTrackCount: AlbumTrackCount? {
    guard let albumArtistName = albumArtistName else { return nil }
    return AlbumTrackCount(album: albumArtistName, trackCount: trackCount)
  }

  var songTrackNumber: SongTrackNumber? {
    guard let songArtistAlbum else { return nil }
    return SongTrackNumber(song: songArtistAlbum, trackNumber: normalizedTrackNumber)
  }

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
  var albumTrackCounts: [AlbumTrackCount] {
    [AlbumTrackCount](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumTrackCount }))
  }

  var songTrackNumbers: [SongTrackNumber] {
    [SongTrackNumber](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songTrackNumber }))
  }

  var trackIdentifiers: [TrackIdentifier] {
    [TrackIdentifier](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.trackIdentifier }))
  }
}

func currentTracks() async throws -> [Track] {
  try await Source.itunes.gather(reduce: false)
}

func currentAlbumTrackCounts() async throws -> [AlbumTrackCount] {
  try await currentTracks().albumTrackCounts
}

func currentSongTrackNumbers() async throws -> [SongTrackNumber] {
  try await currentTracks().songTrackNumbers
}

func currentTrackIdentifiers() async throws -> [TrackIdentifier] {
  try await currentTracks().trackIdentifiers
}
