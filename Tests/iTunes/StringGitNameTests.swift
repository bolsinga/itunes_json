//
//  StringGitNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/1/24.
//

import XCTest

@testable import iTunes

final class StringGitNameTests: XCTestCase {
  func testEmpty() throws {
    XCTAssertEqual("name-empty", "name".emptyTag)
  }

  func testNext_none() throws {
    XCTAssertEqual("name.01", "name".nextTag)
  }

  func testNext_incremental() throws {
    XCTAssertEqual("name.02", "name.1".nextTag)
  }

  func testNext_incrementalWithLeadingZero() throws {
    XCTAssertEqual("name.02", "name.01".nextTag)
  }

  func testNext_notCannonical() throws {
    XCTAssertEqual("name.it.now", "name.it.now".nextTag)
  }

  func testNext_notCannonicalIntegral() throws {
    XCTAssertEqual("name.it.1", "name.it.1".nextTag)
  }

  func testNext_notIntegral() throws {
    XCTAssertEqual("name.it", "name.it".nextTag)
  }
}
