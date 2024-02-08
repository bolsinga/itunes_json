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
      if !remedy.validate(critera) {
        return false
      }
    }

    return true
  }
}
