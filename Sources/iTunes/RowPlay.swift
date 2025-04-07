//
//  RowPlay.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowPlayInterface {
  func songPlayedInformation(_ validation: TrackValidation) -> (
    itunesid: String, datePlayedISO8601: String, playCount: Int
  )
}

struct RowPlay: Hashable, Sendable {
  init?(_ play: RowPlayInterface, validation: TrackValidation) {
    let info = play.songPlayedInformation(validation)

    guard info.playCount > 0 || !info.datePlayedISO8601.isEmpty else { return nil }

    self.init(itunesid: info.itunesid, date: info.datePlayedISO8601, delta: info.playCount)
  }

  init() {
    self.init(itunesid: "", date: "", delta: 0)
  }

  private init(itunesid: String, date: String, delta: Int) {
    self.itunesid = itunesid
    self.date = date
    self.delta = delta
  }

  let itunesid: String
  let date: String
  let delta: Int

  var insert: Database.Statement {
    "INSERT INTO plays (date, delta, itunesid) VALUES (\(date), \(delta), \(itunesid));"
  }
}
