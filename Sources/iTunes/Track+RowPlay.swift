//
//  Track+RowPlay.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  fileprivate var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  fileprivate var songPlayCount: Int {
    playCount ?? 0
  }

  fileprivate var hasPlayed: Bool {
    // Some songs have play dates but not play counts!
    songPlayCount > 0 || !datePlayedISO8601.isEmpty
  }

  func rowPlay(using song: RowSong) -> RowPlay? {
    // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
    guard hasPlayed else { return nil }

    return RowPlay(date: datePlayedISO8601, delta: songPlayCount, song: song)
  }
}
