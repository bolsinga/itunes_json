//
//  SongArtistAlbum+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/23/24.
//

import Foundation

extension SongArtistAlbum: Similar {
  var cullable: Bool {
    self.album == nil
  }

  func isSimilar(to other: SongArtistAlbum) -> Bool {
    // self is the current here.
    self.songArtist.isSimilar(to: other.songArtist)
  }
}
