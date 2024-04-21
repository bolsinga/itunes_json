//
//  RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation
import os

protocol RowAlbumInterface {
  func albumName(logger: Logger) -> SortableName
  func albumTrackCount(logger: Logger) -> Int
  var albumDiscCount: Int { get }
  var albumDiscNumber: Int { get }
  var albumIsCompilation: Int { get }
}

struct RowAlbum: Hashable, Sendable {
  init(_ album: RowAlbumInterface, validation: TrackValidation) {
    self.init(
      name: album.albumName(logger: validation.noAlbum),
      trackCount: album.albumTrackCount(logger: validation.noTrackCount),
      discCount: album.albumDiscCount, discNumber: album.albumDiscNumber,
      compilation: album.albumIsCompilation)
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

  var selectID: Database.Statement {
    "(SELECT id FROM albums WHERE name = \(name.name) AND trackcount = \(trackCount) AND disccount = \(discCount) AND discnumber = \(discNumber) AND compilation = \(compilation))"
  }

  var insert: Database.Statement {
    "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(name.name), \(name.sorted), \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
