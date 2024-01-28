//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowPlayInterface {
  var songPlayedInformation: (datePlayedISO8601: String, playCount: Int) { get }
}

struct RowPlay: Hashable {
  init?(_ play: RowPlayInterface) {
    let info = play.songPlayedInformation

    guard info.playCount > 0 || !info.datePlayedISO8601.isEmpty else { return nil }

    self.init(date: info.datePlayedISO8601, delta: info.playCount)
  }

  init() {
    self.init(date: "", delta: 0)
  }

  private init(date: String, delta: Int) {
    self.date = date
    self.delta = delta
  }

  let date: String
  let delta: Int

  func insert(songid: String) -> String {
    "INSERT INTO plays (date, delta, songid) VALUES (\(sql: date, options:.quoted), \(sql: delta), \(sql: songid));"
  }
}
