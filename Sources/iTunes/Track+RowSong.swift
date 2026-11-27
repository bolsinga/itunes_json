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

  func songTrackNumber() throws -> Int {
    try requiredNumber(\.trackNumber)
  }

  func songYear() throws -> Int {
    try requiredNumber(\.year)
  }

  func songDuration() throws -> Int {
    try requiredNumber(\.totalTime)
  }

  var dateAddedISO8601: String {
    guard let dateAdded else { return "" }
    return dateAdded
  }
}
