//
//  Song+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/24/24.
//

import Foundation

extension Track {
  fileprivate var sortableSongName: SortableName {
    SortableName(name: name, sorted: sortName ?? "")
  }

  var songArtist: SongArtist? {
    guard let artistName else { return nil }
    return SongArtist(song: sortableSongName, artist: artistName)
  }

  var songArtistAlbum: SongArtistAlbum? {
    guard let songArtist else { return nil }
    return SongArtistAlbum(songArtist: songArtist, album: albumName)
  }
}

extension Array where Element == Track {
  var songArtistAlbums: [SongArtistAlbum] {
    [SongArtistAlbum](Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songArtistAlbum }))
  }
}

func currentSongArtistAlbums() async throws -> [SongArtistAlbum] {
  try await Source.itunes.gather(reduce: false).songArtistAlbums
}
