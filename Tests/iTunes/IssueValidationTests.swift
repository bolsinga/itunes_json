//
//  IssueValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import XCTest

@testable import iTunes

final class IssueValidationTests: XCTestCase {
  func testNoRemedies() throws {
    let i = Issue.create(criteria: [.artist("a")], remedies: [])

    XCTAssertNil(i)
  }

  func testNoCriteria() throws {
    let i = Issue.create(criteria: [], remedies: [.ignore])

    XCTAssertNil(i)
  }

  func testCriteriaRemedyInvalid() throws {
    let i = Issue.create(criteria: [.album("l")], remedies: [.ignore])

    XCTAssertNil(i)
  }

  func testCriteriaRemedyValid() throws {
    let i = Issue.create(criteria: [.artist("a")], remedies: [.ignore])

    XCTAssertNotNil(i)
  }
}
