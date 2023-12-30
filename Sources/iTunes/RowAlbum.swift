//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowAlbum: SQLRow {
  let name: String
  let sortName: String
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Int

  init(_ track: Track) {
    self.name = track.albumName
    if let potentialSortName = track.sortAlbum?.quoteEscaped {
      self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
    } else {
      self.sortName = ""
    }
    self.trackCount = track.albumTrackCount
    self.discCount = track.albumDiscCount
    self.discNumber = track.albumDiscNumber
    self.compilation = track.albumIsCompilation
  }

  var insertStatement: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\(name)', '\(sortName)', \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
