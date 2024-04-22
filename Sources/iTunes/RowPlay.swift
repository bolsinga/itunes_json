//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowPlayInterface {
  func songPlayedInformation(_ validation: TrackValidation) -> (
    datePlayedISO8601: String, playCount: Int
  )
}

struct RowPlay: Hashable, Sendable {
  init?(_ play: RowPlayInterface, validation: TrackValidation) {
    let info = play.songPlayedInformation(validation)

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
    "INSERT INTO plays (date, delta, songid) VALUES (\(sql: date, options:.quoteEscaped), \(sql: delta), \(sql: songid));"
  }
}
