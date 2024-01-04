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

  var select: String {
    preconditionFailure("Not Implemented")
  }

  var insert: String {
    "INSERT INTO plays (songid, date, delta) VALUES (\(song.select), \(date, sqlOptions:.quoted), \(delta));"
  }
}
