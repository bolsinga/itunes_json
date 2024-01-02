//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowSong: SQLRow {
  let name: SortableName
  let itunesid: UInt
  @QuoteEscaped var composer: String
  let trackNumber: Int
  let year: Int
  let size: UInt64
  let duration: Int
  let dateAdded: String
  let dateReleased: String
  let dateModified: String
  @QuoteEscaped var comments: String
  let artistSelect: String
  let albumSelect: String
  @QuoteEscaped var kind: String

  var kindSelect: String {
    "SELECT id FROM kinds WHERE name = '\($kind)'"
  }

  var insertStatement: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES ('\(name.$name)', '\(name.$sorted)', '\(itunesid)', (\(artistSelect)), (\(albumSelect)), (\(kindSelect)), '\($composer)', \(trackNumber), \(year), \(size), \(duration), '\(dateAdded)', '\(dateReleased)', '\(dateModified)', '\($comments)');"
  }
}
