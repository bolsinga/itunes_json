//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowArtist: SQLRow {
  let name: String
  let sortName: String

  init(_ track: Track) {
    self.name = track.artistName
    if let potentialSortName = (track.sortArtist ?? track.sortAlbumArtist)?.quoteEscaped {
      self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
    } else {
      self.sortName = ""
    }
  }

  var insertStatement: String {
    "INSERT INTO artists (name, sortname) VALUES ('\(name)', '\(sortName)');"
  }
}
