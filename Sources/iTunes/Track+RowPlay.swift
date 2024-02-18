//
//  Track+RowPlay.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noPlayDate = Logger(type: "validation", category: "noPlayDate")
  static let noPlayCount = Logger(type: "validation", category: "noPlayCount")
}

extension Track: RowPlayInterface {
  var songPlayedInformation: (datePlayedISO8601: String, playCount: Int) {
    let datePlayed = datePlayedISO8601
    let playCount = songPlayCount

    if datePlayed.isEmpty || playCount == 0 {
      if playCount != 0 {
        Logger.noPlayDate.error("\(debugLogInformation, privacy: .public)")
      }
      if !datePlayed.isEmpty {
        Logger.noPlayCount.error("\(debugLogInformation, privacy: .public)")
      }
    }

    return (datePlayed, playCount)
  }

  private var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  private var songPlayCount: Int {
    guard let playCount else { return 0 }
    return playCount
  }
}
