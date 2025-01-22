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

typealias SongYear = SongIntCorrection

extension SongYear {
  init(song: SongArtistAlbum, year: Int?) {
    self.init(song: song, value: year)
  }

  var year: Int? { value }
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

  var songYear: SongYear? {
    guard let songArtistAlbum else { return nil }
    return SongYear(song: songArtistAlbum, year: year)
  }

  var songIdentifier: SongIdentifier? {
    guard let songArtistAlbum else { return nil }
    return SongIdentifier(song: songArtistAlbum, persistentID: persistentID)
  }

  var trackIdentifier: TrackIdentifier? {
    guard let songIdentifier else { return nil }
    return TrackIdentifier(
      songIdentifier: songIdentifier, trackNumber: normalizedTrackNumber,
      trackCount: normalizedTrackCount,
      discNumber: albumDiscNumber, discCount: albumDiscCount)
  }
}

extension Array where Element == Track {
  var albumNames: [AlbumArtistName] {
    [AlbumArtistName](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName }))
  }

  var albumTrackCounts: [AlbumTrackCount] {
    [AlbumTrackCount](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumTrackCount }))
  }

  var songTrackNumbers: [SongTrackNumber] {
    [SongTrackNumber](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songTrackNumber }))
  }

  var songYears: [SongYear] {
    [SongYear](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songYear }))
  }

  var songIdentifiers: [SongIdentifier] {
    [SongIdentifier](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songIdentifier }))
  }

  var trackIdentifiers: [TrackIdentifier] {
    [TrackIdentifier](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.trackIdentifier }))
  }
}

func currentAlbums() async throws -> [AlbumArtistName] {
  try await Source.itunes.gather(reduce: false).albumNames
}

func currentAlbumTrackCounts() async throws -> [AlbumTrackCount] {
  try await Source.itunes.gather(reduce: false).albumTrackCounts
}

func currentSongTrackNumbers() async throws -> [SongTrackNumber] {
  try await Source.itunes.gather(reduce: false).songTrackNumbers
}

func currentSongYears() async throws -> [SongYear] {
  try await Source.itunes.gather(reduce: false).songYears
}

func currentSongIdentifiers() async throws -> [SongIdentifier] {
  try await Source.itunes.gather(reduce: false).songIdentifiers
}

func currentTrackIdentifiers() async throws -> [TrackIdentifier] {
  try await Source.itunes.gather(reduce: false).trackIdentifiers
}
