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
  case replacePersistentIDs
  case replaceDateAddeds
}
