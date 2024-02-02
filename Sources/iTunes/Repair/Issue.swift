//
//  Issue.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

enum Remedy {
  case ignore

  var isIgnored: Bool {
    switch self {
    case .ignore:
      return true
    }
  }
}

enum Criterion {
  case artist(String)
  case song(String)

  func matchesArtist(_ artist: String) -> Bool {
    switch self {
    case .artist(let string):
      return string == artist
    case .song(_):
      return false
    }
  }

  func matchesSong(_ song: String) -> Bool {
    switch self {
    case .artist(_):
      return false
    case .song(let string):
      return string == song
    }
  }
}

struct Issue {
  let critera: [Criterion]
  let remedies: [Remedy]
}
