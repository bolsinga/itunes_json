//
//  Track+RowArtist.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Logger {
  static let noArtist = Logger(subsystem: "sql", category: "noArtist")
}

extension Track {
  fileprivate var artistName: SortableName {
    guard let name = (artist ?? albumArtist ?? nil) else {
      Logger.noArtist.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: name, sorted: (sortArtist ?? sortAlbumArtist) ?? "")
  }

  var rowArtist: RowArtist {
    RowArtist(name: artistName)
  }
}
