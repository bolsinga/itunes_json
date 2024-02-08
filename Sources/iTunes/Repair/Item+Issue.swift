//
//  Item+Issue.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Item {
  var issue: Issue? {
    let issue = Issue(critera: problem.criteria, remedies: fix.remedies)
    guard issue.isValid else { return nil }
    return issue
  }
}
