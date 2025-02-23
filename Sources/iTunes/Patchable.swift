//
//  Patchable.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation

enum Patchable: String, CaseIterable {
  case replaceDurations
  case replacePersistentIds
  case replaceDateAddeds
  case replaceComposers
  case replaceComments
  case replaceDateReleased
  case replaceAlbumTitle
  case replaceSongTitle
  case replaceYear
  case replaceTrackNumber
  case replaceIdSongTitle
  case replaceIdDiscCount
  case replaceIdDiscNumber
  case replaceArtist
  case replacePlay
}
