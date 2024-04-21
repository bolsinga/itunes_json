//
//  SQLiteStatementTests.swift
//
//
//  Created by Greg Bolsinga on 5/19/24.
//

import XCTest

@testable import iTunes

final class SQLiteStatementTests: XCTestCase {
  func testSimple() throws {
    let statement: Database.Statement = "Here \(String("we 'go'")) On \(Int(3))"
    XCTAssertEqual("Here 'we ''go''' On 3", statement.description)
    XCTAssertEqual("Here ? On ?", statement.sql)
  }

  func testExtraEnd() throws {
    let statement: Database.Statement = "Here \(String("we 'go'")) On \(Int(3)) some more"
    XCTAssertEqual("Here 'we ''go''' On 3 some more", statement.description)
    XCTAssertEqual("Here ? On ? some more", statement.sql)
  }
}
