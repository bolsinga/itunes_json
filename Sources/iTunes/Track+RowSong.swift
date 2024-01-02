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
    RowSong(self)
  }
}
