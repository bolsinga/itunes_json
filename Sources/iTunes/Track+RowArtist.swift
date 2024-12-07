//
//  Track+RowArtist.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Track: RowArtistInterface {
  var artistName: SortableName? {
    guard let name = (artist ?? albumArtist ?? nil) else { return nil }
    return SortableName(name: name, sorted: (sortArtist ?? sortAlbumArtist) ?? "")
  }

  func artistName(logger: Logger) -> SortableName {
    guard let artistName = self.artistName else {
      logger.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return artistName
  }
}
