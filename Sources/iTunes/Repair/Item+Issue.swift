//
//  Item+Issue.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Array where Element == Criterion {
  var validForIgnore: Bool {
    guard count == 1 else { return false }

    switch self[0] {
    case .artist(_):
      return true
    case .song(_):
      return true
    default:
      return false
    }
  }

  var validForSortArtist: Bool {
    guard count == 1 else { return false }

    switch self[0] {
    case .artist(_):
      return true
    default:
      return false
    }
  }

  var validForKind: Bool {
    guard count == 3 else { return false }

    var matchingCriteriaCount = 0
    for criteria in self {
      switch criteria {
      case .album(_), .artist(_), .song(_):
        matchingCriteriaCount += 1
      }
    }
    return matchingCriteriaCount == 3
  }
}

extension Item {
  var issue: Issue? {
    let issue = Issue(critera: problem.criteria, remedies: fix.remedies)
    guard issue.isValid else { return nil }
    return issue
  }
}
