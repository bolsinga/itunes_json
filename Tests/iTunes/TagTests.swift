//
//  TagTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/5/24.
//

import Testing

@testable import iTunes

struct TagTests {
  @Test func test_StandardFormat() throws {
    #expect("ZZZ-2024-10-25".tagPrefix() == "ZZZ")
  }

  @Test func test_VersionFormat() throws {
    #expect("ZZZ-2024-10-25.01".tagPrefix() == "ZZZ")
  }

  @Test func test_EmptyFormat() throws {
    #expect("ZZZ-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func test_VersionEmptyFormat() throws {
    #expect("ZZZ-2024-10-25.02-empty".tagPrefix() == nil)
  }

  @Test func test_RandomFormat() throws {
    #expect("ZZZ-2024".tagPrefix() == nil)
    #expect("ZZZ.2024".tagPrefix() == nil)
    #expect("ZZZ-2024-10".tagPrefix() == nil)
    #expect("ZZZ.2024.10".tagPrefix() == nil)
    #expect("ZZZ-2024-10.25".tagPrefix() == nil)
    #expect("ZZZ-2024.10.25".tagPrefix() == nil)
  }

  @Test func test_EmbeddedHyphen() throws {
    #expect("ZZZ-A-2024-10-25".tagPrefix() == "ZZZ-A")
    #expect("ZZZ-A-2024-10-25.01".tagPrefix() == "ZZZ-A")
    #expect("ZZZ-A-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func test_EmbeddedPeriod() throws {
    #expect("ZZZ.A-2024-10-25".tagPrefix() == "ZZZ.A")
    #expect("ZZZ.A-2024-10-25.01".tagPrefix() == "ZZZ.A")
    #expect("ZZZ.A-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func test_MultipleEmbeddedHyphen() throws {
    #expect("ZZZ-A-B-2024-10-25".tagPrefix() == "ZZZ-A-B")
    #expect("ZZZ-A-B-2024-10-25.01".tagPrefix() == "ZZZ-A-B")
    #expect("ZZZ-A-B-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func test_MultipleEmbeddedPeriod() throws {
    #expect("ZZZ.A.B-2024-10-25".tagPrefix() == "ZZZ.A.B")
    #expect("ZZZ.A.B-2024-10-25.01".tagPrefix() == "ZZZ.A.B")
    #expect("ZZZ.A.B-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func leadingHyphen() throws {
    #expect("-ZZZ-2024-10-25".tagPrefix() == "-ZZZ")
    #expect("-ZZZ-2024-10-25.01".tagPrefix() == "-ZZZ")
    #expect("-ZZZ-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func doubleTrailingHyphen() throws {
    #expect("ZZZ--2024-10-25".tagPrefix() == "ZZZ-")
    #expect("ZZZ--2024-10-25.01".tagPrefix() == "ZZZ-")
    #expect("ZZZ--2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func tripleTrailingHyphen() throws {
    #expect("ZZZ---2024-10-25".tagPrefix() == "ZZZ--")
    #expect("ZZZ---2024-10-25.01".tagPrefix() == "ZZZ--")
    #expect("ZZZ---2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func leadingPeriod() throws {
    #expect(".ZZZ-2024-10-25".tagPrefix() == ".ZZZ")
    #expect(".ZZZ-2024-10-25.01".tagPrefix() == ".ZZZ")
    #expect(".ZZZ-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func doubleTrailingPeriod() throws {
    #expect("ZZZ..-2024-10-25".tagPrefix() == "ZZZ..")
    #expect("ZZZ..-2024-10-25.01".tagPrefix() == "ZZZ..")
    #expect("ZZZ..-2024-10-25-empty".tagPrefix() == nil)
  }

  @Test func weirdPrefixes() throws {
    #expect(".-2024-10-25".tagPrefix() == ".")
    #expect("..-2024-10-25".tagPrefix() == "..")
    #expect("--2024-10-25.01".tagPrefix() == "-")
    #expect("---2024-10-25.01".tagPrefix() == "--")
  }

  @Test func noPrefix() throws {
    #expect("-2024-10-25".tagPrefix() == nil)
    #expect("2024-10-25".tagPrefix() == nil)
  }

  @Test func matchingEmpty() throws {
    #expect(!"tag-2024-12-05".matchingFormattedTag(prefix: ""))
  }

  @Test func matchingInvalidPrefix() throws {
    #expect(!"-2024-12-05".matchingFormattedTag(prefix: "tag"))
  }

  @Test func matchingNonConforming() throws {
    #expect(!"xxxxx".matchingFormattedTag(prefix: "tag"))
  }

  @Test func matchingWrongPrefix() throws {
    #expect(!"tag-2024-12-05".matchingFormattedTag(prefix: "x"))
  }

  @Test func matchingPrefix() throws {
    #expect("tag-2024-12-05".matchingFormattedTag(prefix: "tag"))
  }

  @Test func replaceInvalid() throws {
    #expect("-2024-12-05".replacePrefix(newPrefix: "X") == nil)
  }

  @Test func replaceNonConforming() throws {
    #expect("xxxxx".replacePrefix(newPrefix: "X") == nil)
  }

  @Test func replace() throws {
    #expect("tag-2024-12-05".replacePrefix(newPrefix: "X") == "X-2024-12-05")
  }
}
