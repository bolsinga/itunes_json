//
//  Track+RowPlay.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  fileprivate var hasPlayed: Bool {
    // Some songs have play dates but not play counts!
    songPlayCount > 0 || !datePlayedISO8601.isEmpty
  }

  var rowPlay: RowPlay? {
    // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
    guard hasPlayed else { return nil }

    return RowPlay(self)
  }
}
