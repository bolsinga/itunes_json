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

  fileprivate var songSelect: String {
    "SELECT id FROM songs WHERE name = '\(songName.$name)' AND itunesid = '\(persistentID)' AND artistid = (\(artistSelect)) AND albumid = (\(albumSelect)) AND kindid = (\(kindSelect)) AND tracknumber = \(songTrackNumber) AND year = \(songYear) AND size = \(songSize) AND duration = \(songDuration) AND dateadded = '\(dateAddedISO8601)'"
  }

  var rowPlay: RowPlay? {
    // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
    guard hasPlayed else { return nil }

    return RowPlay(date: datePlayedISO8601, delta: playCount ?? 0, songSelect: songSelect)
  }
}
