//
//  Issue.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
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

enum Criterion {
  case album(String)
  case artist(String)
  case song(String)

  func matchesAlbum(_ album: String) -> Bool {
    switch self {
    case .album(let string):
      return string == album
    default:
      return false
    }
  }

  func matchesArtist(_ artist: String) -> Bool {
    switch self {
    case .artist(let string):
      return string == artist
    default:
      return false
    }
  }

  func matchesSong(_ song: String) -> Bool {
    switch self {
    case .song(let string):
      return string == song
    default:
      return false
    }
  }
}

struct Issue {
  let criteria: [Criterion]
  let remedies: [Remedy]
}
