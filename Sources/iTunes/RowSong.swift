//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowSong: TrackRowItem {
  let name: SortableName
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
}

extension RowSong {
  func selectID(artistID: String, albumID: String, kindID: String) -> String {
    "(SELECT id FROM songs WHERE name = \(sql: name.name, options:.safeQuoted) AND itunesid = \(sql: itunesid, options: .quoted) AND artistid = \(sql: artistID) AND albumid = \(sql: albumID) AND kindid = \(sql: kindID) AND tracknumber = \(sql: trackNumber) AND year = \(sql: year) AND size = \(sql: size) AND duration = \(sql: duration) AND dateadded = \(sql: dateAdded, options: .quoted))"
  }
}

extension RowSong {
  func insert(artistID: String, albumID: String, kindID: String) -> String {
    "INSERT INTO songs (name, sortname, itunesid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments, artistid, albumid, kindid) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted), \(sql: itunesid, options: .quoted), \(sql: composer, options:.safeQuoted), \(sql: trackNumber), \(sql: year), \(sql: size), \(sql: duration), \(sql: dateAdded, options:.quoted), \(sql: dateReleased, options:.quoted), \(sql: dateModified, options:.quoted), \(sql: comments, options:.safeQuoted), \(sql: artistID), \(sql: albumID), \(sql: kindID));"
  }
}
