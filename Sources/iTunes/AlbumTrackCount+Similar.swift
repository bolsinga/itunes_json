//
//  AlbumTrackCount+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/23/24.
//

import Foundation

extension AlbumTrackCount: Similar {
  var cullable: Bool {
    true  // FIXME
  }

  func isSimilar(to other: AlbumTrackCount) -> Bool {
    // self is the current here.
    self.album.isSimilar(to: other.album)
  }
}
