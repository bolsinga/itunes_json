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
    #expect("name.it-empty" == "name.it".emptyTag)
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

  @Test func next_withDots_incremental() {
    #expect("name.it.02" == "name.it.1".nextTag)
  }

  @Test func next_withDots_incrementalWithLeadingZero() {
    #expect("name.it.02" == "name.it.01".nextTag)
  }

  @Test func next_notIntegral() {
    #expect("name.it.01" == "name.it".nextTag)
  }

  @Test func next_wacky() {
    #expect("name.02.02" == "name.01.01".nextTag)  // Bug
    #expect("name.01.02" != "name.01.01".nextTag)  // Desired
  }

  @Test func next_whee() {
    #expect("iTunes.artists-2024-12-11.03" == "iTunes.artists-2024-12-11.02".nextTag)
  }
}
