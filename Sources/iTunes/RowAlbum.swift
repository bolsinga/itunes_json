//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct RowAlbum: TrackRowItem {
  let name: SortableName
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Int
}

extension RowAlbum: SQLSelectID {
  var selectID: String {
    "(SELECT id FROM albums WHERE name = \(sql: name.name, options:.safeQuoted) AND trackcount = \(sql: trackCount) AND disccount = \(sql: discCount) AND discnumber = \(sql: discNumber) AND compilation = \(sql: compilation))"
  }
}

extension RowAlbum {
  var insert: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted), \(sql: trackCount), \(sql: discCount), \(sql: discNumber), \(sql: compilation));"
  }
}
