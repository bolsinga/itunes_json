//
//  Patchable.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/2/24.
//

import Foundation

enum Patchable: String, CaseIterable {
  case artists
  case albums
  case missingTitleAlbums
  case missingTrackCounts
  case trackCorrections
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
}
