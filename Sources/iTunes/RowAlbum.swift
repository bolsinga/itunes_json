//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowAlbum: SQLRow {
  let name: SortableName
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Int

  var select: String {
    "SELECT id FROM albums WHERE name = '\(name.$name)' AND trackcount = \(trackCount) AND disccount = \(discCount) AND discnumber = \(discNumber) AND compilation = \(compilation)"
  }

  var insert: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\(name.$name)', '\(name.$sorted)', \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
