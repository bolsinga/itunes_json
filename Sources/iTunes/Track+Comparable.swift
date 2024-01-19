//
//  Track+Comparable.swift
//
//
//  Created by Greg Bolsinga on 1/19/24.
//

import Foundation

extension Track: Comparable {
  fileprivate var compareArtist: String { artist ?? albumArtist ?? "" }

  fileprivate var compareAlbum: String { album ?? "" }

  fileprivate var compareDiscNumber: Int { discNumber ?? 1 }

  fileprivate var compareTrackNumber: Int { trackNumber ?? 1 }

  public static func < (lhs: Track, rhs: Track) -> Bool {
    let lhArtist = lhs.compareArtist
    let rhArtist = rhs.compareArtist

    if lhArtist == rhArtist {
      let lhAlbum = lhs.compareAlbum
      let rhAlbum = rhs.compareAlbum

      if lhAlbum == rhAlbum {
        let lhDiscNumber = lhs.compareDiscNumber
        let rhDiscNumber = rhs.compareDiscNumber

        if lhDiscNumber == rhDiscNumber {
          return lhs.compareTrackNumber < rhs.compareTrackNumber
        }
        return lhDiscNumber < rhDiscNumber
      }
      return lhAlbum < rhAlbum
    }
    return lhArtist < rhArtist
  }
}
