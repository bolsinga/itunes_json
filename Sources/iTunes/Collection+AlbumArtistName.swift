//
//  Collection+AlbumArtistName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/11/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let albumCorrection = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "albumCorrection")
}

extension Collection where Element == AlbumArtistName {
  public func correctedSimilarName(to other: Element, corrections: [String: String]) -> Element? {
    var similarValid = self.similarName(to: other)
    if similarValid == nil, let correction = corrections[other.name.name] {
      Logger.albumCorrection.log("Corrected \(other.name.name) to \(correction)")
      switch correction {
      case "--COMPILATION--":
        // Change named album to a compilation.
        similarValid = self.similarName(to: other.updateToCompilation())
      default:
        // Change the name of the album.
        similarValid = self.similarName(to: other.update(name: correction))
      }
    }
    return similarValid
  }
}
