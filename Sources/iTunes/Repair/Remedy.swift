//
//  Remedy.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

enum Remedy {
  case ignore
  case repairEmptyAlbum(String)
  case repairEmptyKind(String)
  case repairEmptySortArtist(String)
  case repairEmptyTrackCount(Int)
  case repairEmptyYear(Int)
  case replaceArtist(String)

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
    case .repairEmptySortArtist(let string):
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
    case .repairEmptyTrackCount(let int):
      return int
    default:
      return nil
    }
  }

  var album: String? {
    switch self {
    case .repairEmptyAlbum(let string):
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
}
