//
//  Repairable.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/25/24.
//

import Foundation

enum Repairable: CaseIterable {
  case artists
  case albums
  case missingTitleAlbums
  case missingTrackCounts
  case missingTrackNumbers
  case missingYears
  case songs
  case replaceTrackCounts
  case replaceDiscCounts
  case replaceDiscNumbers
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
