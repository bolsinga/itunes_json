//
//  Issue.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

enum Remedy {
  case ignore
  case correctSortArtist(String)
  case correctKind(String)
  case correctTrackCount(Int)
  case correctYear(Int)
  case correctAlbum(String)
  case correctArtist(String)

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
    case .correctSortArtist(let string):
      return string
    default:
      return nil
    }
  }

  var kind: String? {
    switch self {
    case .correctKind(let string):
      return string
    default:
      return nil
    }
  }

  var year: Int? {
    switch self {
    case .correctYear(let int):
      return int
    default:
      return nil
    }
  }

  var trackCount: Int? {
    switch self {
    case .correctTrackCount(let int):
      return int
    default:
      return nil
    }
  }

  var album: String? {
    switch self {
    case .correctAlbum(let string):
      return string
    default:
      return nil
    }
  }

  var artist: String? {
    switch self {
    case .correctArtist(let string):
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
  let critera: [Criterion]
  let remedies: [Remedy]
}
