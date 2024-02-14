//
//  Track+SQLLogging.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  var debugLogInformation: String {
    "album: \(String(describing: album)), artist: \(String(describing: artist)), name: \(name), trackCount: \(String(describing: trackCount)), trackNumber: \(String(describing: trackNumber)), year: \(String(describing: year)), playCount: \(String(describing: playCount)), playDate: \(String(describing: playDateUTC))"
  }
}
