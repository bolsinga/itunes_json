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
  let songSelect: String

  var insertStatement: String {
    "INSERT INTO plays (songid, date, delta) VALUES ((\(songSelect)), '\(date)', \(delta));"
  }
}
