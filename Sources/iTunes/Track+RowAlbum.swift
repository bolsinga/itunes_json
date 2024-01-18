//
//  Track+RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noAlbum = Logger(subsystem: "validation", category: "noAlbum")
  static let noTrackCount = Logger(subsystem: "validation", category: "noTrackCount")
}

extension Track: RowAlbumInterface {
  var albumName: SortableName {
    guard let album else {
      Logger.noAlbum.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: album, sorted: sortAlbum ?? "")
  }

  var albumTrackCount: Int {
    guard let trackCount else {
      Logger.noTrackCount.error("\(debugLogInformation, privacy: .public)")
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
