//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowSongInterface {
  var songPersistentID: UInt { get }
  var songComposer: String { get }
  var songComments: String { get }
  var dateReleasedISO8601: String { get }
  var songName: SortableName { get }
  var songTrackNumber: Int { get }
  var songYear: Int { get }
  var songDuration: Int { get }
  var dateAddedISO8601: String { get }
}

struct RowSong: Hashable {
  init(_ song: RowSongInterface) {
    self.init(
      name: song.songName, itunesid: song.songPersistentID, composer: song.songComposer,
      trackNumber: song.songTrackNumber, year: song.songYear, duration: song.songDuration,
      dateAdded: song.dateAddedISO8601, dateReleased: song.dateReleasedISO8601,
      comments: song.songComments)
  }

  private init(
    name: SortableName, itunesid: UInt, composer: String, trackNumber: Int, year: Int,
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
      name: SortableName(), itunesid: 0, composer: "", trackNumber: 0, year: 0, duration: 0,
      dateAdded: "", dateReleased: "", comments: "")
  }

  let name: SortableName
  let itunesid: UInt
  let composer: String
  let trackNumber: Int
  let year: Int
  let duration: Int
  let dateAdded: String
  let dateReleased: String
  let comments: String
}

extension RowSong {
  func selectID(artistID: String, albumID: String) -> String {
    "(SELECT id FROM songs WHERE name = \(sql: name.name, options:.safeQuoted) AND itunesid = \(sql: itunesid, options: .quoted) AND artistid = \(sql: artistID) AND albumid = \(sql: albumID) AND tracknumber = \(sql: trackNumber) AND year = \(sql: year) AND duration = \(sql: duration) AND dateadded = \(sql: dateAdded, options: .quoted))"
  }
}

extension RowSong {
  func insert(artistID: String, albumID: String) -> String {
    "INSERT INTO songs (name, sortname, itunesid, composer, tracknumber, year, duration, dateadded, datereleased, comments, artistid, albumid) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted), \(sql: itunesid, options: .quoted), \(sql: composer, options:.safeQuoted), \(sql: trackNumber), \(sql: year), \(sql: duration), \(sql: dateAdded, options:.quoted), \(sql: dateReleased, options:.quoted), \(sql: comments, options:.safeQuoted), \(sql: artistID), \(sql: albumID));"
  }
}
