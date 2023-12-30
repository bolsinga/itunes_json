//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowSong: SQLRow {
  let name: String
  let sortName: String
  let itunesid: UInt
  let composer: String
  let trackNumber: Int
  let year: Int
  let size: UInt64
  let duration: Int
  let dateAdded: String
  let dateReleased: String
  let dateModified: String
  let comments: String
  let artistSelect: String
  let albumSelect: String
  let kindSelect: String

  init(_ track: Track) {
    self.name = track.songName
    if let potentialSortName = track.sortName?.quoteEscaped {
      self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
    } else {
      self.sortName = ""
    }
    self.itunesid = track.persistentID
    self.composer = (track.composer ?? "").quoteEscaped
    self.trackNumber = track.songTrackNumber
    self.year = track.songYear
    self.size = track.songSize
    self.duration = track.songDuration
    self.dateAdded = track.dateAddedISO8601
    self.dateReleased = track.dateReleasedISO8601
    self.dateModified = track.dateModifiedISO8601
    self.comments = (track.comments ?? "").quoteEscaped
    self.artistSelect = track.artistSelect
    self.albumSelect = track.albumSelect
    self.kindSelect = track.kindSelect
  }

  var insertStatement: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES ('\(name)', '\(sortName)', '\(itunesid)', (\(artistSelect)), (\(albumSelect)), (\(kindSelect)), '\(composer)', \(trackNumber), \(year), \(size), \(duration), '\(dateAdded)', '\(dateReleased)', '\(dateModified)', '\(comments)');"
  }
}
