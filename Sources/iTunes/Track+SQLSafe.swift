//
//  Track+SQLSafe.swift
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
  var debugLogInformation: String {
    "album: \(String(describing: album)), artist: \(String(describing: artist)), kind: \(String(describing: kind)), name: \(name), podcast: \(String(describing: podcast)), trackCount: \(String(describing: trackCount)), trackNumber: \(String(describing: trackNumber)), year: \(String(describing: year))"
  }

  var artistName: SortableName {
    guard let name = (artist ?? albumArtist ?? nil) else {
      Logger.noArtist.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: name, sorted: (sortArtist ?? sortAlbumArtist) ?? "")
  }
}
