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
  public func correctedSimilarName(to other: Element, correction: AlbumCorrection) -> Element? {
    var similarValid = self.similarName(to: other)
    if similarValid == nil {
      if let rename = correction.rename[other.name.name] {
        Logger.albumCorrection.log("Rename \(other.name.name) to \(rename)")
        similarValid = self.similarName(to: other.update(name: rename))
      } else if correction.compilation.contains(other.name.name) {
        Logger.albumCorrection.log("compilation \(other.name.name)")
        similarValid = self.similarName(to: other.updateToCompilation())
      }
    }
    return similarValid
  }
}
