//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowPlay: TrackRowItem {
  let date: String
  let delta: Int
}

extension RowPlay {
  func insert(songid: String) -> String {
    "INSERT INTO plays (songid, date, delta) VALUES (\(sql: songid), \(sql: date, options:.quoted), \(sql: delta));"
  }
}
