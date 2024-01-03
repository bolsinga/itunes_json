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
  let kind: RowKind

  var select: String {
    "SELECT id FROM songs WHERE name = \(name.$name) AND itunesid = '\(itunesid)' AND artistid = (\(artist.select)) AND albumid = (\(album.select)) AND kindid = (\(kind.select)) AND tracknumber = \(trackNumber) AND year = \(year) AND size = \(size) AND duration = \(duration) AND dateadded = '\(dateAdded)'"
  }

  var insert: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES (\(name.$name), \(name.$sorted), '\(itunesid)', (\(artist.select)), (\(album.select)), (\(kind.select)), \($composer), \(trackNumber), \(year), \(size), \(duration), '\(dateAdded)', '\(dateReleased)', '\(dateModified)', \($comments));"
  }
}
