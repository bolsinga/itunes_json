//
//  Track+RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  var rowAlbum: RowAlbum {
    RowAlbum(
      name: albumName, trackCount: albumTrackCount, discCount: albumDiscCount,
      discNumber: albumDiscNumber, compilation: albumIsCompilation)
  }
}
