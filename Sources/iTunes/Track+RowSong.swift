//
//  Track+RowSong.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  var dateReleasedISO8601: String {
    guard let releaseDate else { return "" }
    return releaseDate.formatted(.iso8601)
  }

  var dateModifiedISO8601: String {
    guard let dateModified else { return "" }
    return dateModified.formatted(.iso8601)
  }

  var rowSong: RowSong {
    RowSong(
      name: songName, itunesid: persistentID, composer: composer ?? "",
      trackNumber: songTrackNumber, year: songYear, size: songSize, duration: songDuration,
      dateAdded: dateAddedISO8601, dateReleased: dateReleasedISO8601,
      dateModified: dateModifiedISO8601, comments: comments ?? "", artistSelect: artistSelect,
      albumSelect: albumSelect, kindSelect: kindSelect)
  }
}
