//
//  Track+RowAlbum.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noAlbum = Logger(subsystem: "sql", category: "noAlbum")
  static let noTrackCount = Logger(subsystem: "sql", category: "noTrackCount")
}

extension Track {
  fileprivate var albumName: SortableName {
    guard let album else {
      Logger.noAlbum.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: album, sorted: sortAlbum ?? "")
  }

  fileprivate var albumTrackCount: Int {
    guard let trackCount else {
      Logger.noTrackCount.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackCount
  }

  fileprivate var albumDiscCount: Int {
    discCount ?? 1
  }

  fileprivate var albumDiscNumber: Int {
    discNumber ?? 1
  }

  fileprivate var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }

  var rowAlbum: RowAlbum {
    RowAlbum(
      name: albumName, trackCount: albumTrackCount, discCount: albumDiscCount,
      discNumber: albumDiscNumber, compilation: albumIsCompilation)
  }
}
