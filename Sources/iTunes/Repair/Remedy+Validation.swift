//
//  Remedy+Validation.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation
import os

extension Remedy {
  func validate(_ criteria: Set<Criterion>, loggingToken: String? = nil) -> Bool {
    switch self {
    case .ignore:
      guard criteria.validForIgnore else {
        Logger(type: "repair", category: "ignore", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSortArtist(_):
      guard criteria.validForSortArtist else {
        Logger(type: "repair", category: "sortArtist", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyKind(_):
      guard criteria.validForKind else {
        Logger(type: "repair", category: "kind", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyYear(_):
      guard criteria.validForYear else {
        Logger(type: "repair", category: "year", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceTrackCount(_):
      guard criteria.validForTrackCount else {
        Logger(type: "repair", category: "trackCount", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .repairEmptyTrackNumber(_):
      guard criteria.validForTrackNumber else {
        Logger(type: "repair", category: "trackNumber", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceAlbum(_):
      guard criteria.validForAlbum else {
        Logger(type: "repair", category: "album", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceArtist(_):
      guard criteria.validForArtist else {
        Logger(type: "repair", category: "artist", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replacePlayCount(_):
      guard criteria.validForPlayCount else {
        Logger(type: "repair", category: "playCount", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replacePlayDate(_):
      guard criteria.validForPlayDate else {
        Logger(type: "repair", category: "playDate", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceSong(_):
      guard criteria.validForSong else {
        Logger(type: "repair", category: "song", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscCount(_):
      guard criteria.validForDiscCount else {
        Logger(type: "repair", category: "discCount", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    case .replaceDiscNumber(_):
      guard criteria.validForDiscNumber else {
        Logger(type: "repair", category: "discNumber", token: loggingToken).error(
          "\(String(describing: self), privacy: .public)")
        return false
      }
    }
    return true
  }
}
