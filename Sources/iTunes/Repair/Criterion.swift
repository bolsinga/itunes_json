//
//  Criterion.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

enum Criterion: Hashable {
  case album(String)
  case artist(String)
  case song(String)
  case playCount(Int)

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

  func matchesPlayCount(_ playCount: Int) -> Bool {
    switch self {
    case .playCount(let int):
      return int == playCount
    default:
      return false
    }
  }
}
