//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowPlay<Song>: SQLRow where Song: SQLSelectID, Song: Hashable {
  let date: String
  let delta: Int
  let song: Song
}

extension RowPlay: SQLInsert {
  var insert: String {
    "INSERT INTO plays (songid, date, delta) VALUES (\(song.selectID), \(date, options:.quoted), \(delta));"
  }
}
