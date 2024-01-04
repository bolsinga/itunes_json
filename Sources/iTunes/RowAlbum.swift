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
    "(SELECT id FROM albums WHERE name = \(name.name, sqlOptions:.quoted) AND trackcount = \(trackCount) AND disccount = \(discCount) AND discnumber = \(discNumber) AND compilation = \(compilation))"
  }

  var insert: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(name.name, sqlOptions:.quoted), \(name.sorted, sqlOptions:.quoted), \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
