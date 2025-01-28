//
//  Track+RowPlay.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Track: RowPlayInterface {
  func songPlayedInformation(_ validation: TrackValidation) -> (
    datePlayedISO8601: String, playCount: Int
  ) {
    let datePlayed = datePlayedISO8601
    let playCount = songPlayCount

    if datePlayed.isEmpty || playCount == 0 {
      if playCount != 0 {
        validation.noPlayDate.error("\(debugLogInformation, privacy: .public)")
      }
      if !datePlayed.isEmpty {
        validation.noPlayCount.error("\(debugLogInformation, privacy: .public)")
      }
    }

    return (datePlayed, playCount)
  }

  var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  private var songPlayCount: Int {
    guard let playCount else { return 0 }
    return playCount
  }
}
