//
//  Collection+AlbumTrackCount.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/23/24.
//

import Foundation

extension Collection where Element == AlbumTrackCount {
  func needsChangeAndSimilar(to other: Element) -> Element? {
    // 'self' contains the current names here.
    if other.trackCount == nil {
      // trackCount is nil, so it needs to be
      //  changed if it is similar.
      return self.similarName(to: other)
    }
    return nil
  }
}
