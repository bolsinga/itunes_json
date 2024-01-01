//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowAlbum: SQLRow {
  private let name: SortableName
  private let trackCount: Int
  private let discCount: Int
  private let discNumber: Int
  private let compilation: Int

  init(_ track: Track) {
    self.name = track.albumName
    self.trackCount = track.albumTrackCount
    self.discCount = track.albumDiscCount
    self.discNumber = track.albumDiscNumber
    self.compilation = track.albumIsCompilation
  }

  var insertStatement: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\(name.name)', '\(name.sorted)', \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
