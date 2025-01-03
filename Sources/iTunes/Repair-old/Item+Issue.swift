//
//  Item+Issue.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Item {
  func issue() -> Issue? {
    Issue.create(criteria: problem.criteria, remedies: fix.remedies)
  }
}
