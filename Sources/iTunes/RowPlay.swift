//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowPlay: SQLRow {
  private let date: String
  private let delta: Int
  private let songSelect: String

  init(_ track: Track) {
    self.date = track.datePlayedISO8601
    self.delta = track.playCount ?? 0
    self.songSelect = track.songSelect
  }

  var insertStatement: String {
    "INSERT INTO plays (songid, date, delta) VALUES ((\(songSelect)), '\(date)', \(delta));"
  }
}
