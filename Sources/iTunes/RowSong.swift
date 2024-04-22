//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation
import os

protocol RowSongInterface {
  var songPersistentID: String { get }
  var songComposer: String { get }
  var songComments: String { get }
  var dateReleasedISO8601: String { get }
  var songName: SortableName { get }
  func songTrackNumber(validation: TrackValidation) -> Int
  func songYear(logger: Logger) -> Int
  var songDuration: Int { get }
  var dateAddedISO8601: String { get }
}

struct RowSong: Hashable, Sendable {
  init(_ song: RowSongInterface, validation: TrackValidation) {
    self.init(
      name: song.songName, itunesid: song.songPersistentID, composer: song.songComposer,
      trackNumber: song.songTrackNumber(validation: validation),
      year: song.songYear(logger: validation.noYear), duration: song.songDuration,
      dateAdded: song.dateAddedISO8601, dateReleased: song.dateReleasedISO8601,
      comments: song.songComments)
  }

  private init(
    name: SortableName, itunesid: String, composer: String, trackNumber: Int, year: Int,
    duration: Int, dateAdded: String, dateReleased: String, comments: String
  ) {
    self.name = name
    self.itunesid = itunesid
    self.composer = composer
    self.trackNumber = trackNumber
    self.year = year
    self.duration = duration
    self.dateAdded = dateAdded
    self.dateReleased = dateReleased
    self.comments = comments
  }

  init() {
    self.init(
      name: SortableName(), itunesid: String(0), composer: "", trackNumber: 0, year: 0, duration: 0,
      dateAdded: "", dateReleased: "", comments: "")
  }

  let name: SortableName
  let itunesid: String
  let composer: String
  let trackNumber: Int
  let year: Int
  let duration: Int
  let dateAdded: String
  let dateReleased: String
  let comments: String

  func selectID(artistID: String, albumID: String) -> String {
    "(SELECT id FROM songs WHERE name = \(sql: name.name, options:.quoteEscaped) AND itunesid = \(sql: itunesid, options: .quoteEscaped) AND artistid = \(sql: artistID) AND albumid = \(sql: albumID) AND tracknumber = \(sql: trackNumber) AND year = \(sql: year) AND duration = \(sql: duration) AND dateadded = \(sql: dateAdded, options: .quoteEscaped))"
  }

  func insert(artistID: String, albumID: String) -> String {
    "INSERT INTO songs (name, sortname, itunesid, composer, tracknumber, year, duration, dateadded, datereleased, comments, artistid, albumid) VALUES (\(sql: name.name, options:.quoteEscaped), \(sql: name.sorted, options:.quoteEscaped), \(sql: itunesid, options: .quoteEscaped), \(sql: composer, options:.quoteEscaped), \(sql: trackNumber), \(sql: year), \(sql: duration), \(sql: dateAdded, options:.quoteEscaped), \(sql: dateReleased, options:.quoteEscaped), \(sql: comments, options:.quoteEscaped), \(sql: artistID), \(sql: albumID));"
  }
}
