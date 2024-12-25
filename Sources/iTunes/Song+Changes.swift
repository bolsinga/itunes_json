//
//  Song+Changes.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/24/24.
//

import Foundation

extension Track {
  var songArtist: SongArtist? {
    guard let artistName else { return nil }
    return SongArtist(song: name, artist: artistName.name)
  }

  var songArtistAlbum: SongArtistAlbum? {
    guard let songArtist else { return nil }
    return SongArtistAlbum(songArtist: songArtist, album: albumName)
  }
}

extension Array where Element == Track {
  var songArtistAlbums: Set<SongArtistAlbum> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.songArtistAlbum })
  }
}

func currentSongArtistAlbums() async throws -> Set<SongArtistAlbum> {
  try await Source.itunes.gather(reduce: false).songArtistAlbums
}
