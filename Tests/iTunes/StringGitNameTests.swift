//
//  StringGitNameTests.swift
//
//
//  Created by Greg Bolsinga on 4/1/24.
//

import Testing

@testable import iTunes

struct StringGitNameTests {
  @Test func empty() {
    #expect("name-empty" == "name".emptyTag)
  }

  @Test func next_none() {
    #expect("name.01" == "name".nextTag)
  }

  @Test func next_incremental() {
    #expect("name.02" == "name.1".nextTag)
  }

  @Test func next_incrementalWithLeadingZero() {
    #expect("name.02" == "name.01".nextTag)
  }

  @Test func next_notCannonical() {
    #expect("name.it.now" == "name.it.now".nextTag)
  }

  @Test func next_notCannonicalIntegral() {
    #expect("name.it.1" == "name.it.1".nextTag)
  }

  @Test func next_notIntegral() {
    #expect("name.it" == "name.it".nextTag)
  }
}
