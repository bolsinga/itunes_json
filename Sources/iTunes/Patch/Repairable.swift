//
//  Repairable.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/25/24.
//

import Foundation

enum Repairable: CaseIterable {
  case replaceDurations
  case replacePersistentIds
  case replaceDateAddeds
  case replaceComposers
  case replaceComments
  case replaceDateReleased
  case replaceAlbumTitle
  case replaceYear
  case replaceTrackNumber
  case replaceIdSongTitle
  case replaceIdDiscCount
  case replaceIdDiscNumber
  case replaceArtist
  case replacePlay

  case libraryRepairs
  case historyRepairs

  case allRepairs
}
