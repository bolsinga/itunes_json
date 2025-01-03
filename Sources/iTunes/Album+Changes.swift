//
//  Album+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation

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
}

extension Array where Element == Track {
  var albumNames: Set<AlbumArtistName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName })
  }

  var albumTrackCounts: Set<AlbumTrackCount> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumTrackCount })
  }

  var songTrackNumbers: Set<SongTrackNumber> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songTrackNumber })
  }
}

func currentAlbums() async throws -> Set<AlbumArtistName> {
  try await Source.itunes.gather(reduce: false).albumNames
}

func currentAlbumTrackCounts() async throws -> Set<AlbumTrackCount> {
  try await Source.itunes.gather(reduce: false).albumTrackCounts
}

func currentSongTrackNumbers() async throws -> Set<SongTrackNumber> {
  try await Source.itunes.gather(reduce: false).songTrackNumbers
}
