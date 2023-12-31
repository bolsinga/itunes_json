//
//  RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowArtist: SQLRow {
  let name: SortableName

  init(_ track: Track) {
    self.name = SortableName(
      name: track.artistName,
      sorted: (track.sortArtist ?? track.sortAlbumArtist)?.quoteEscaped ?? "")
  }

  var insertStatement: String {
    "INSERT INTO artists (name, sortname) VALUES ('\(name.name)', '\(name.sorted)');"
  }
}
