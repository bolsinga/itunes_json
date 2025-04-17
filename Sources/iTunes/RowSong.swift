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
  var songName: SortableName { get }
  func normalizedTrackNumber(validation: TrackValidation) -> Int
  func songYear(logger: Logger) -> Int
  var songDuration: Int { get }
}

struct RowSong: Hashable, Sendable {
  init(_ song: RowSongInterface, validation: TrackValidation) {
    self.init(
      name: song.songName, itunesid: song.songPersistentID, composer: song.songComposer,
      trackNumber: song.normalizedTrackNumber(validation: validation),
      year: song.songYear(logger: validation.noYear), duration: song.songDuration,
      comments: song.songComments)
  }

  private init(
    name: SortableName, itunesid: String, composer: String, trackNumber: Int, year: Int,
    duration: Int, comments: String
  ) {
    self.name = name
    self.itunesid = itunesid
    self.composer = composer
    self.trackNumber = trackNumber
    self.year = year
    self.duration = duration
    self.comments = comments
  }

  init() {
    self.init(
      name: SortableName(), itunesid: String(0), composer: "", trackNumber: 0, year: 0, duration: 0,
      comments: "")
  }

  let name: SortableName
  let itunesid: String
  let composer: String
  let trackNumber: Int
  let year: Int
  let duration: Int
  let comments: String

  func insert(artistID: Database.Statement, albumID: Database.Statement) -> Database.Statement {
    "INSERT INTO songs (itunesid, name, sortname, composer, tracknumber, year, duration, comments, artistid, albumid) VALUES (\(itunesid), \(name.name), \(name.sorted), \(composer), \(trackNumber), \(year), \(duration), \(comments), \(artistID), \(albumID));"
  }
}
