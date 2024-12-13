//
//  Remedy+Validation.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation
import os

extension Remedy {
  func validate(_ criteria: Set<Criterion>) -> Bool {
    switch self {
    case .ignore:
      guard criteria.validForIgnore else {
        Logger(type: "repair", category: "ignore", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSortArtist(_):
      guard criteria.validForSortArtist else {
        Logger(type: "repair", category: "sortArtist", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyKind(_):
      guard criteria.validForKind else {
        Logger(type: "repair", category: "kind", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyYear(_):
      guard criteria.validForYear else {
        Logger(type: "repair", category: "year", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceTrackCount(_):
      guard criteria.validForTrackCount else {
        Logger(type: "repair", category: "trackCount", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyTrackNumber(_):
      guard criteria.validForTrackNumber else {
        Logger(type: "repair", category: "trackNumber", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceAlbum(_):
      guard criteria.validForAlbum else {
        Logger(type: "repair", category: "album", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceArtist(_):
      guard criteria.validForArtist else {
        Logger(type: "repair", category: "artist", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replacePlayCount(_):
      guard criteria.validForPlayCount else {
        Logger(type: "repair", category: "playCount", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replacePlayDate(_):
      guard criteria.validForPlayDate else {
        Logger(type: "repair", category: "playDate", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSong(_):
      guard criteria.validForSong else {
        Logger(type: "repair", category: "song", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscCount(_):
      guard criteria.validForDiscCount else {
        Logger(type: "repair", category: "discCount", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscNumber(_):
      guard criteria.validForDiscNumber else {
        Logger(type: "repair", category: "discNumber", token: nil).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    }
    return true
  }
}
