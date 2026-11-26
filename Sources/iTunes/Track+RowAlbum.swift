//
//  Track+RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Track: RowAlbumInterface {
  var albumName: SortableName? {
    guard let album else { return nil }
    return SortableName(name: album, sorted: sortAlbum ?? "")
  }

  func albumName(logger: Logger) -> SortableName {
    guard let albumName = self.albumName else {
      logger.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return albumName
  }

  func albumTrackCount() throws -> Int {
    try requiredNumber(\.trackCount)
  }

  var albumDiscCount: Int {
    discCount.positive ?? 1
  }

  var albumDiscNumber: Int {
    discNumber.positive ?? 1
  }

  var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }

  var albumArtistName: SortableName? {
    artistName
  }
}
