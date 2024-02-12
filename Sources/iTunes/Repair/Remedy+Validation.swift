//
//  Remedy+Validation.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation
import os

extension Logger {
  static let ignore = Logger(subsystem: "repair", category: "ignore")
  static let sortArtist = Logger(subsystem: "repair", category: "sortArtist")
  static let kind = Logger(subsystem: "repair", category: "kind")
  static let year = Logger(subsystem: "repair", category: "year")
  static let trackCount = Logger(subsystem: "repair", category: "trackCount")
  static let trackNumber = Logger(subsystem: "repair", category: "trackNumber")
  static let album = Logger(subsystem: "repair", category: "album")
  static let artist = Logger(subsystem: "repair", category: "artist")
  static let playCount = Logger(subsystem: "repair", category: "playCount")
}

extension Remedy {
  func validate(_ criteria: Set<Criterion>) -> Bool {
    switch self {
    case .ignore:
      guard criteria.validForIgnore else {
        Logger.ignore.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptySortArtist(_):
      guard criteria.validForSortArtist else {
        Logger.sortArtist.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyKind(_):
      guard criteria.validForKind else {
        Logger.kind.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyYear(_):
      guard criteria.validForYear else {
        Logger.year.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyTrackCount(_):
      guard criteria.validForTrackCount else {
        Logger.trackCount.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyTrackNumber(_):
      guard criteria.validForTrackNumber else {
        Logger.trackNumber.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyAlbum(_):
      guard criteria.validForAlbum else {
        Logger.album.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceArtist(_):
      guard criteria.validForArtist else {
        Logger.artist.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replacePlayCount(_):
      guard criteria.validForPlayCount else {
        Logger.playCount.error("\(String(describing: self), privacy: .public)")
        return false
      }
    }
    return true
  }
}
