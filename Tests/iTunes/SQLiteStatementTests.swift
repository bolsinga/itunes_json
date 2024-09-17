//
//  SQLiteStatementTests.swift
//
//
//  Created by Greg Bolsinga on 5/19/24.
//

import Testing

@testable import iTunes

struct SQLiteStatementTests {
  @Test func simple() {
    let statement: Database.Statement = "Here \(String("we 'go'")) On \(Int(3))"
    #expect("Here 'we ''go''' On 3" == statement.description)
    #expect("Here ? On ?" == statement.sql)
  }

  @Test func extraEnd() {
    let statement: Database.Statement = "Here \(String("we 'go'")) On \(Int(3)) some more"
    #expect("Here 'we ''go''' On 3 some more" == statement.description)
    #expect("Here ? On ? some more" == statement.sql)
  }
}
