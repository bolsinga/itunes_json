//
//  Track+RowSong.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Track: RowSongInterface {
  var songPersistentID: String {
    String(persistentID)
  }

  var songComposer: String {
    composer ?? ""
  }

  var songComments: String {
    comments ?? ""
  }

  var dateReleasedISO8601: String {
    guard let releaseDate else { return "" }
    return releaseDate
  }

  var songName: SortableName {
    SortableName(name: name, sorted: sortName ?? "")
  }

  var normalizedTrackNumber: Int? {
    trackNumber.positive
  }

  func normalizedTrackNumber(validation: TrackValidation) -> Int {
    guard let normalizedTrackNumber else {
      validation.invalidTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return .missing
    }
    return normalizedTrackNumber
  }

  func songYear(logger: Logger) -> Int {
    guard let year = year.positive else {
      logger.error("\(debugLogInformation, privacy: .public)")
      return .missing
    }
    return year
  }

  var songDuration: Int {
    totalTime.positive ?? .missing
  }

  var dateAddedISO8601: String {
    guard let dateAdded else { return "" }
    return dateAdded
  }
}
