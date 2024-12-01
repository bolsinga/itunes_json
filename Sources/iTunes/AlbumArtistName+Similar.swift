//
//  AlbumArtistName+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

extension AlbumArtistName: Similar {
  var cullable: Bool {
    true  // FIXME
  }

  func isSimilar(to other: AlbumArtistName) -> Bool {
    // self is the current here.
    self.name.isSimilar(to: other.name) && self.type.isSimilar(to: other.type)
  }
}
