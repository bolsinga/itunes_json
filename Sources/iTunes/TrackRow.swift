//
//  TrackRow.swift
//
//
//  Created by Greg Bolsinga on 1/8/24.
//

import Foundation

struct TrackRow {
  typealias SongRow = RowSong<RowArtist>

  let kind: RowKind
  let album: RowAlbum
  let song: SongRow
  let play: RowPlay?
}
