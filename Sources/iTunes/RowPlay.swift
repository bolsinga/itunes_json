//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowPlayInterface {
  var datePlayedISO8601: String { get }
  var songPlayCount: Int { get }
}

extension RowPlayInterface {
  fileprivate var hasPlayed: Bool {
    // Some songs have play dates but not play counts!
    songPlayCount > 0 || !datePlayedISO8601.isEmpty
  }
}

struct RowPlay: Hashable {
  init?(_ play: RowPlayInterface) {
    // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
    guard play.hasPlayed else { return nil }

    self.init(date: play.datePlayedISO8601, delta: play.songPlayCount)
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
