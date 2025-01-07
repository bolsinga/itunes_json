//
//  Collection+SortableName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let correction = Logger(category: "correction")
}

extension Collection where Element == SortableName {
  func correctedSimilarName(to other: Element, corrections: [String: String]) -> Element? {
    var similarValid = self.similarName(to: other)
    if similarValid == nil, let correction = corrections[other.name] {
      Logger.correction.log("Corrected \(other.name) to \(correction)")
      similarValid = self.similarName(to: SortableName(name: correction))
    }
    return similarValid
  }
}
