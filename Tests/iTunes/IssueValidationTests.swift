//
//  IssueValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import Testing

@testable import iTunes

struct IssueValidationTests {
  @Test func noRemedies() {
    let i = Issue.create(criteria: [.artist("a")], remedies: [])

    #expect(i == nil)
  }

  @Test func noCriteria() {
    let i = Issue.create(criteria: [], remedies: [.ignore])

    #expect(i == nil)
  }

  @Test func criteriaRemedyInvalid() {
    let i = Issue.create(criteria: [.album("l")], remedies: [.ignore])

    #expect(i == nil)
  }

  @Test func criteriaRemedyValid() {
    let i = Issue.create(criteria: [.artist("a")], remedies: [.ignore])

    #expect(i != nil)
  }
}
