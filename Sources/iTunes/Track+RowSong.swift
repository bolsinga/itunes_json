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

extension Track: RowSongInterface {
  var songPersistentID: UInt {
    persistentID
  }

  var songComposer: String {
    composer ?? ""
  }

  var songComments: String {
    comments ?? ""
  }

  var dateReleasedISO8601: String {
    guard let releaseDate else { return "" }
    return releaseDate.formatted(.iso8601)
  }

  var songName: SortableName {
    SortableName(name: name, sorted: sortName ?? "")
  }

  var songTrackNumber: Int {
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

  var songYear: Int {
    guard let year else {
      Logger.noYear.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return year
  }

  var songDuration: Int {
    totalTime ?? -1
  }

  var dateAddedISO8601: String {
    guard let dateAdded else { preconditionFailure() }
    return dateAdded.formatted(.iso8601)
  }
}
