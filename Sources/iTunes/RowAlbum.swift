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
  var albumArtistName: SortableName? { get }
}

struct RowAlbum: Hashable, Sendable {
  init(_ album: RowAlbumInterface, validation: TrackValidation) {
    self.init(
      name: album.albumName(logger: validation.noAlbum),
      trackCount: album.albumTrackCount(logger: validation.noTrackCount),
      discCount: album.albumDiscCount, discNumber: album.albumDiscNumber,
      compilation: album.albumIsCompilation, albumArtistName: album.albumArtistName)
  }

  init() {
    self.init(
      name: SortableName(), trackCount: 0, discCount: 0, discNumber: 0, compilation: 0,
      albumArtistName: SortableName())
  }

  private init(
    name: SortableName, trackCount: Int, discCount: Int, discNumber: Int, compilation: Int,
    albumArtistName: SortableName?
  ) {
    self.name = name
    self.trackCount = trackCount
    self.discCount = discCount
    self.discNumber = discNumber
    self.compilation = compilation
    self.albumArtistName = albumArtistName
  }

  let name: SortableName
  let trackCount: Int
  let discCount: Int
  let discNumber: Int
  let compilation: Int
  // The following isn't referenced, but its value contributes to Hashable, which will make an album with different artists but otherwise exactly the same be different albums.
  let albumArtistName: SortableName?

  var selectID: Database.Statement {
    "(SELECT id FROM albums WHERE name = \(name.name) AND trackcount = \(trackCount) AND disccount = \(discCount) AND discnumber = \(discNumber) AND compilation = \(compilation))"
  }

  func insert(artistID: Database.Statement) -> Database.Statement {
    "INSERT INTO albums (artistid, name, sortname, trackcount, disccount, discnumber, compilation) VALUES (\(artistID), \(name.name), \(name.sorted), \(trackCount), \(discCount), \(discNumber), \(compilation));"
  }
}
