//
//  SongArtist+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/24/24.
//

import Foundation

extension SongArtist: Similar {
  var cullable: Bool {
    true  // FIXME
  }

  func isSimilar(to other: SongArtist) -> Bool {
    // self is the current here.
    self.song.isSimilar(to: other.song) && self.artist.isSimilar(to: other.artist)
  }
}
