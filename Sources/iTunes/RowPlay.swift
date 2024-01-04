//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowPlay: SQLRow {
  let date: String
  let delta: Int
  let song: RowSong
}

extension RowPlay: SQLInsert {
  var insert: String {
    "INSERT INTO plays (songid, date, delta) VALUES (\(song.selectID), \(date, sql:.quoted), \(delta));"
  }
}
