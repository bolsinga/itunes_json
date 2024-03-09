//
//  Track+RowSong.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noTrackNumber = Logger(type: "validation", category: "noTrackNumber")
  static let badTrackNumber = Logger(type: "validation", category: "badTrackNumber")
  static let noYear = Logger(type: "validation", category: "noYear")
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

  func songTrackNumber(validation: TrackValidation) -> Int {
    guard let trackNumber else {
      validation.noTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    guard trackNumber > 0 else {
      validation.badTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackNumber
  }

  func songYear(logger: Logger) -> Int {
    guard let year else {
      logger.error("\(debugLogInformation, privacy: .public)")
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
