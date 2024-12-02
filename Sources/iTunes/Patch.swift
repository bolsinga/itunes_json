//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

public enum Patch {
  case artists([ArtistPatch])
  case albums([AlbumPatch])
}

extension Patch: CustomStringConvertible {
  public var description: String {
    switch self {
    case .artists(let artists):
      return (try? (try? artists.sorted().jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.sorted().jsonData())?.asUTF8String()) ?? ""
    }
  }
}
