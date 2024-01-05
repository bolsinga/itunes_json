//
//  RowSong.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowSong<
  Artist: SQLSelectID & Hashable, Album: SQLSelectID & Hashable, Kind: SQLSelectID & Hashable
>: SQLRow {
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
  let artist: Artist
  let album: Album
  let kind: Kind
}

extension RowSong: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM songs WHERE name = \(name.name, sql:.safeQuoted) AND itunesid = \(itunesid, sql: .quoted) AND artistid = \(artist.selectID) AND albumid = \(album.selectID) AND kindid = \(kind.selectID) AND tracknumber = \(trackNumber) AND year = \(year) AND size = \(size) AND duration = \(duration) AND dateadded = \(dateAdded, sql: .quoted))"
  }
}

extension RowSong: SQLInsert {
  var insert: String {
    "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES (\(name.name, sql:.safeQuoted), \(name.sorted, sql:.safeQuoted), \(itunesid, sql: .quoted), \(artist.selectID), \(album.selectID), \(kind.selectID), \(composer, sql:.safeQuoted), \(trackNumber), \(year), \(size), \(duration), \(dateAdded, sql:.quoted), \(dateReleased, sql:.quoted), \(dateModified, sql:.quoted), \(comments, sql:.safeQuoted));"
  }
}
