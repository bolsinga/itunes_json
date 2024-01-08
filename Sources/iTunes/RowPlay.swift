//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowPlay<Song>: TrackRowItem where Song: SQLSelectID, Song: Hashable {
  let date: String
  let delta: Int
  let song: Song
}

extension RowPlay: SQLInsert {
  var insert: String {
    "INSERT INTO plays (songid, date, delta) VALUES (\(sql: song.selectID), \(sql: date, options:.quoted), \(sql: delta));"
  }
}
