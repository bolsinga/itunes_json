//
//  Track+RowSong.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noTrackNumber = Logger(subsystem: "validation", category: "noTrackNumber")
  static let badTrackNumber = Logger(subsystem: "validation", category: "badTrackNumber")
  static let noYear = Logger(subsystem: "validation", category: "noYear")
}

extension Track {
  fileprivate var dateReleasedISO8601: String {
    guard let releaseDate else { return "" }
    return releaseDate.formatted(.iso8601)
  }

  fileprivate var songName: SortableName {
    SortableName(name: name, sorted: sortName ?? "")
  }

  fileprivate var songTrackNumber: Int {
    guard let trackNumber else {
      Logger.noTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    guard trackNumber > 0 else {
      Logger.badTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackNumber
  }

  fileprivate var songYear: Int {
    guard let year else {
      Logger.noYear.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return year
  }

  fileprivate var songDuration: Int {
    totalTime ?? -1
  }

  fileprivate var dateAddedISO8601: String {
    guard let dateAdded else { preconditionFailure() }
    return dateAdded.formatted(.iso8601)
  }

  var rowSong: RowSong {
    RowSong(
      name: songName, itunesid: persistentID, composer: composer ?? "",
      trackNumber: songTrackNumber, year: songYear, duration: songDuration,
      dateAdded: dateAddedISO8601, dateReleased: dateReleasedISO8601, comments: comments ?? "")
  }
}
