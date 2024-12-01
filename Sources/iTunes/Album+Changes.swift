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
      return .compilation
    } else if let artistName = artistName {
      return .artist(artistName.name)
    } else {
      return .unknown
    }
  }

  fileprivate var albumArtistName: AlbumArtistName? {
    guard let albumName else { return nil }
    return AlbumArtistName(name: albumName, type: albumType)
  }
}

extension Array where Element == Track {
  public var albumNames: Set<AlbumArtistName> {
    Set(self.filter { $0.isSQLEncodable }.compactMap { $0.albumArtistName })
  }
}

public func currentAlbums() async throws -> Set<AlbumArtistName> {
  let tracks = try await Source.itunes.gather(
    nil, repair: nil, artistIncluded: nil, reduce: false)
  return tracks.albumNames
}
