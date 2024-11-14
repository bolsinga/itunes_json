//
//  Track+RowArtist.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation
import os

extension Track: RowArtistInterface {
  public func artistName(logger: Logger) -> SortableName {
    guard let name = (artist ?? albumArtist ?? nil) else {
      logger.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: name, sorted: (sortArtist ?? sortAlbumArtist) ?? "")
  }
}
