//
//  TrackRow.swift
//
//
//  Created by Greg Bolsinga on 1/8/24.
//

import Foundation

struct TrackRow {
  typealias SongRow = RowSong<RowArtist, RowAlbum>

  let kind: RowKind
  let song: SongRow
  let play: RowPlay?
}
