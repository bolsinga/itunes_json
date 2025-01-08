//
//  StructuredTagTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/7/25.
//

import Testing

@testable import iTunes

struct StructuredTagTests {
  @Test func description() async throws {
    #expect(
      StructuredTag(
        root: "aRoot", version: 33, stamp: "2025-01-07.23"
      ).description == "aRoot-V33-2025-01-07.23")
  }

  @Test func comparisons() async throws {
    let tags = [
      StructuredTag(root: "iTunes", version: 1, stamp: "2006-01-01"),
      StructuredTag(root: "iTunes", version: 8, stamp: "2006-01-01"),
      StructuredTag(root: "iTunes", version: 8, stamp: "2006-01-01.01"),
      StructuredTag(root: "iTunes", version: 9, stamp: "2006-01-02"),
      StructuredTag(root: "iTunes", version: 10, stamp: "2006-01-02"),
    ]

    #expect(tags.shuffled().sorted() == tags)
  }
}
