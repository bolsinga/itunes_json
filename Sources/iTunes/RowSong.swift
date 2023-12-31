//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowSong: SQLRow {
  private let name: SortableName
  private let itunesid: UInt
  private let composer: String
  private let trackNumber: Int
  private let year: Int
  private let size: UInt64
  private let duration: Int
  private let dateAdded: String
  private let dateReleased: String
  private let dateModified: String
  private let comments: String
  private let artistSelect: String
  private let albumSelect: String
  private let kindSelect: String

  init(_ track: Track) {
    self.name = SortableName(name: track.songName, sorted: track.sortName?.quoteEscaped ?? "")
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
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES ('\(name.name)', '\(name.sorted)', '\(itunesid)', (\(artistSelect)), (\(albumSelect)), (\(kindSelect)), '\(composer)', \(trackNumber), \(year), \(size), \(duration), '\(dateAdded)', '\(dateReleased)', '\(dateModified)', '\(comments)');"
  }
}
