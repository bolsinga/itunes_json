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

  func albumTrackCount(logger: Logger) -> Int {
    guard let trackCount else {
      logger.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackCount
  }

  var albumDiscCount: Int {
    discCount ?? 1
  }

  var albumDiscNumber: Int {
    discNumber ?? 1
  }

  var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }
}
