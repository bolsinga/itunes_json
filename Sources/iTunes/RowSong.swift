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
  let composer: String
  let trackNumber: Int
  let year: Int
  let size: UInt64
  let duration: Int
  let dateAdded: String
  let dateReleased: String
  let dateModified: String
  let comments: String
  let artist: RowArtist
  let album: RowAlbum
  let kind: RowKind

  var select: String {
    "(SELECT id FROM songs WHERE name = \(name.name, sqlOptions:.quoted) AND itunesid = \(itunesid, sqlOptions: .quoted) AND artistid = \(artist.select) AND albumid = \(album.select) AND kindid = \(kind.select) AND tracknumber = \(trackNumber) AND year = \(year) AND size = \(size) AND duration = \(duration) AND dateadded = \(dateAdded, sqlOptions: .quoted))"
  }

  var insert: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES (\(name.name, sqlOptions:.quoted), \(name.sorted, sqlOptions:.quoted), \(itunesid, sqlOptions: .quoted), \(artist.select), \(album.select), \(kind.select), \(composer, sqlOptions:.quoted), \(trackNumber), \(year), \(size), \(duration), \(dateAdded, sqlOptions:.quoted), \(dateReleased, sqlOptions:.quoted), \(dateModified, sqlOptions:.quoted), \(comments, sqlOptions:.quoted));"
  }
}
