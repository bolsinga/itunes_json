//
//  Collection+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let similar = Logger(category: "similar")
}

extension Collection where Element: Similar {
  fileprivate func similarNames(to other: Element) -> [Element] {
    self.filter { $0.isSimilar(to: other) }
  }

  func similarName(to other: Element) -> Element? {
    // 'self' contains the current names here.
    var similarNames = self.similarNames(to: other)
    let originalCount = similarNames.count
    var keepLooking = true
    repeat {
      if similarNames.count == 1, let similarName = similarNames.first {
        return similarName
      } else {
        let previousCount = similarNames.count
        similarNames = similarNames.filter { !$0.cullable }
        if similarNames.count == previousCount {
          keepLooking = false
        }
      }
    } while keepLooking

    Logger.similar.log("Candidates (\(originalCount)) for \(String(describing: other))")
    return nil
  }
}
