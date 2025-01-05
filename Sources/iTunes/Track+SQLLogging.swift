//
//  Track+SQLLogging.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  fileprivate var albumInformation: String {
    if let album {
      return "album: \"\(album)\""
    }
    return ""
  }

  fileprivate var artistInformation: String {
    if let artist {
      return "artist: \"\(artist)\""
    }
    return ""
  }

  fileprivate var nPlayCount: Int {
    if let playCount { return playCount }
    return 0
  }

  fileprivate var playCountInformation: String {
    "playCount: \(nPlayCount)"
  }

  fileprivate var nPlayDate: String {
    if let playDateUTC { return "\(playDateUTC)" }
    return "<none>"
  }

  fileprivate var playDateInformation: String {
    "playDate: \"\(nPlayDate)\""
  }

  fileprivate var playInformation: String {
    let info = [
      albumInformation, artistInformation, "name: \"\(name)\"", playCountInformation,
      playDateInformation,
    ]
    return info.filter { !$0.isEmpty }.joined(separator: ", ")
  }

  var debugLogInformation: String {
    "[\(playInformation)]"
  }
}
