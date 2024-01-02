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
  static let noAlbum = Logger(subsystem: "sql", category: "noAlbum")
  static let noTrackCount = Logger(subsystem: "sql", category: "noTrackCount")
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

  var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }

  var songPlayCount: Int {
    playCount ?? 0
  }

  var artistSelect: String {
    "SELECT id FROM artists WHERE name = '\(artistName.$name)'"
  }

  var albumSelect: String {
    "SELECT id FROM albums WHERE name = '\(albumName.$name)' AND trackcount = \(albumTrackCount) AND disccount = \(albumDiscCount) AND discnumber = \(albumDiscNumber) AND compilation = \(albumIsCompilation)"
  }
}
