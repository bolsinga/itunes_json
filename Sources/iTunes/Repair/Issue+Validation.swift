//
//  Issue+Validation.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import Foundation
import os

extension Logger {
  static let noRemedies = Logger(subsystem: "repair", category: "noRemedies")
  static let noCriteria = Logger(subsystem: "repair", category: "noCriteria")
  static let ignore = Logger(subsystem: "repair", category: "ignore")
  static let sortArtist = Logger(subsystem: "repair", category: "sortArtist")
}

extension Issue {
  var isValid: Bool {
    guard !remedies.isEmpty else {
      Logger.noRemedies.error("\(String(describing: self), privacy: .public)")
      return false
    }

    guard !critera.isEmpty else {
      Logger.noCriteria.error("\(String(describing: self), privacy: .public)")
      return false
    }

    for remedy in remedies {
      switch remedy {
      case .ignore:
        guard critera.validForIgnore else {
          Logger.ignore.error("\(String(describing: self), privacy: .public)")
          return false
        }
      case .correctSortArtist(_):
        guard critera.validForSortArtist else {
          Logger.sortArtist.error("\(String(describing: self), privacy: .public)")
          return false
        }
      }
    }

    return true
  }
}
