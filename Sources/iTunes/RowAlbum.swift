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
}

extension RowAlbum: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM albums WHERE name = \(name.name, sql:.safeQuoted) AND trackcount = \(trackCount) AND disccount = \(discCount) AND discnumber = \(discNumber) AND compilation = \(compilation))"
  }
}

extension RowAlbum: SQLInsert {
  var insert: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(name.name, sql:.safeQuoted), \(name.sorted, sql:.safeQuoted), \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
