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
  let artist: RowArtist
  let album: RowAlbum
  @QuoteEscaped var kind: String

  var kindSelect: String {
    "SELECT id FROM kinds WHERE name = '\($kind)'"
  }

  var songSelect: String {
    "SELECT id FROM songs WHERE name = '\(name.$name)' AND itunesid = '\(itunesid)' AND artistid = (\(artist.artistSelect)) AND albumid = (\(album.albumSelect)) AND kindid = (\(kindSelect)) AND tracknumber = \(trackNumber) AND year = \(year) AND size = \(size) AND duration = \(duration) AND dateadded = '\(dateAdded)'"
  }

  var insertStatement: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES ('\(name.$name)', '\(name.$sorted)', '\(itunesid)', (\(artist.artistSelect)), (\(album.albumSelect)), (\(kindSelect)), '\($composer)', \(trackNumber), \(year), \(size), \(duration), '\(dateAdded)', '\(dateReleased)', '\(dateModified)', '\($comments)');"
  }
}
