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
}

extension Array where Element == Track {
  var albumNames: Set<AlbumArtistName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName })
  }
}

func currentAlbums() async throws -> Set<AlbumArtistName> {
  try await Source.itunes.gather(reduce: false).albumNames
}
