//
//  Remedy.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

enum Remedy: Hashable {
  case ignore
  case replaceAlbum(String)
  case repairEmptyKind(String)
  case replaceSortArtist(String)
  case replaceTrackCount(Int)
  case repairEmptyTrackNumber(Int)
  case repairEmptyYear(Int)
  case replaceArtist(String)
  case replacePlayCount(Int)
  case replacePlayDate(Date)
  case replaceSong(String)

  var isIgnored: Bool {
    switch self {
    case .ignore:
      return true
    default:
      return false
    }
  }

  var sortArtist: String? {
    switch self {
    case .replaceSortArtist(let string):
      return string
    default:
      return nil
    }
  }

  var kind: String? {
    switch self {
    case .repairEmptyKind(let string):
      return string
    default:
      return nil
    }
  }

  var year: Int? {
    switch self {
    case .repairEmptyYear(let int):
      return int
    default:
      return nil
    }
  }

  var trackCount: Int? {
    switch self {
    case .replaceTrackCount(let int):
      return int
    default:
      return nil
    }
  }

  var trackNumber: Int? {
    switch self {
    case .repairEmptyTrackNumber(let int):
      return int
    default:
      return nil
    }
  }

  var album: String? {
    switch self {
    case .replaceAlbum(let string):
      return string
    default:
      return nil
    }
  }

  var artist: String? {
    switch self {
    case .replaceArtist(let string):
      return string
    default:
      return nil
    }
  }

  var playCount: Int? {
    switch self {
    case .replacePlayCount(let int):
      return int
    default:
      return nil
    }
  }

  var playDate: Date? {
    switch self {
    case .replacePlayDate(let date):
      return date
    default:
      return nil
    }
  }

  var song: String? {
    switch self {
    case .replaceSong(let string):
      return string
    default:
      return nil
    }
  }
}
