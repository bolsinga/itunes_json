//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation
import os

extension Logger {
  static let brokenPlayDate = Logger(subsystem: "validation", category: "brokenPlayDate")
}

protocol RowPlayInterface {
  var datePlayedISO8601: String { get }
  var songPlayCount: Int { get }
}

struct RowPlay: Hashable {
  init?(_ play: RowPlayInterface) {
    let songPlayCount = play.songPlayCount
    let datePlayed = play.datePlayedISO8601

    // Some tracks have had play dates, but not play counts. This table also has a CHECK(delta > 0) constraint.
    if songPlayCount == 0, !datePlayed.isEmpty {
      Logger.brokenPlayDate.error("")
    }

    guard songPlayCount > 0 || !datePlayed.isEmpty else { return nil }

    self.init(date: datePlayed, delta: songPlayCount)
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
