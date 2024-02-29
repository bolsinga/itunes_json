//
//  Remedy+Validation.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation
import os

extension Logger {
  static let ignore = Logger(type: "repair", category: "ignore")
  static let sortArtist = Logger(type: "repair", category: "sortArtist")
  static let kind = Logger(type: "repair", category: "kind")
  static let year = Logger(type: "repair", category: "year")
  static let trackCount = Logger(type: "repair", category: "trackCount")
  static let trackNumber = Logger(type: "repair", category: "trackNumber")
  static let album = Logger(type: "repair", category: "album")
  static let artist = Logger(type: "repair", category: "artist")
  static let playCount = Logger(type: "repair", category: "playCount")
  static let playDate = Logger(type: "repair", category: "playDate")
  static let song = Logger(type: "repair", category: "song")
  static let discCount = Logger(type: "repair", category: "discCount")
  static let discNumber = Logger(type: "repair", category: "discNumber")
}

extension Remedy {
  func validate(_ criteria: Set<Criterion>) -> Bool {
    switch self {
    case .ignore:
      guard criteria.validForIgnore else {
        Logger.ignore.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSortArtist(_):
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
    case .replaceTrackCount(_):
      guard criteria.validForTrackCount else {
        Logger.trackCount.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyTrackNumber(_):
      guard criteria.validForTrackNumber else {
        Logger.trackNumber.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceAlbum(_):
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
    case .replacePlayDate(_):
      guard criteria.validForPlayDate else {
        Logger.playDate.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSong(_):
      guard criteria.validForSong else {
        Logger.song.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscCount(_):
      guard criteria.validForDiscCount else {
        Logger.discCount.error("\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscNumber(_):
      guard criteria.validForDiscNumber else {
        Logger.discNumber.error("\(String(describing: self), privacy: .public)")
        return false
      }
    }
    return true
  }
}
