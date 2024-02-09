//
//  Issue.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation
import os

extension Logger {
  static let noRemedies = Logger(subsystem: "repair", category: "noRemedies")
  static let noCriteria = Logger(subsystem: "repair", category: "noCriteria")
}

struct Issue {
  static func create(criteria: Set<Criterion>, remedies: Set<Remedy>) -> Issue? {
    guard !remedies.isEmpty else {
      Logger.noRemedies.error("\(String(describing: self), privacy: .public)")
      return nil
    }

    guard !criteria.isEmpty else {
      Logger.noCriteria.error("\(String(describing: self), privacy: .public)")
      return nil
    }

    for remedy in remedies {
      if !remedy.validate(criteria) {
        return nil
      }
    }

    return Issue(criteria: criteria, remedies: remedies)
  }

  private init(criteria: Set<Criterion>, remedies: Set<Remedy>) {
    self.criteria = criteria
    self.remedies = remedies
  }

  let criteria: Set<Criterion>
  let remedies: Set<Remedy>
}
