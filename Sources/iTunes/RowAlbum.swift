//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

protocol RowAlbumInterface {
  var albumName: SortableName { get }
  var albumTrackCount: Int { get }
  var albumDiscCount: Int { get }
  var albumDiscNumber: Int { get }
  var albumIsCompilation: Int { get }
}

struct RowAlbum: Hashable {
  init(_ album: RowAlbumInterface) {
    self.init(
      name: album.albumName, trackCount: album.albumTrackCount, discCount: album.albumDiscCount,
      discNumber: album.albumDiscNumber, compilation: album.albumIsCompilation)
  }

  init() {
    self.init(name: SortableName(), trackCount: 0, discCount: 0, discNumber: 0, compilation: 0)
  }

  private init(
    name: SortableName, trackCount: Int, discCount: Int, discNumber: Int, compilation: Int
  ) {
    self.name = name
    self.trackCount = trackCount
    self.discCount = discCount
    self.discNumber = discNumber
    self.compilation = compilation
  }

  let name: SortableName
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Int

  var selectID: String {
    "(SELECT id FROM albums WHERE name = \(sql: name.name, options:.safeQuoted) AND trackcount = \(sql: trackCount) AND disccount = \(sql: discCount) AND discnumber = \(sql: discNumber) AND compilation = \(sql: compilation))"
  }

  var insert: String {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(sql: name.name, options:.safeQuoted), \(sql: name.sorted, options:.safeQuoted), \(sql: trackCount), \(sql: discCount), \(sql: discNumber), \(sql: compilation));"
  }
}
