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
    #expect(try #require("ZZZ-2024-10-25".tagPrefixAndStamp) == ("ZZZ", "2024-10-25"))
  }

  @Test func test_VersionFormat() throws {
    #expect(try #require("ZZZ-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ", "2024-10-25.01"))
  }

  @Test func test_EmptyFormat() throws {
    #expect("ZZZ-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func test_VersionEmptyFormat() throws {
    #expect("ZZZ-2024-10-25.02-empty".tagPrefixAndStamp == nil)
  }

  @Test func test_RandomFormat() throws {
    #expect("ZZZ-2024".tagPrefixAndStamp == nil)
    #expect("ZZZ.2024".tagPrefixAndStamp == nil)
    #expect("ZZZ-2024-10".tagPrefixAndStamp == nil)
    #expect("ZZZ.2024.10".tagPrefixAndStamp == nil)
    #expect("ZZZ-2024-10.25".tagPrefixAndStamp == nil)
    #expect("ZZZ-2024.10.25".tagPrefixAndStamp == nil)
  }

  @Test func test_EmbeddedHyphen() throws {
    #expect(try #require("ZZZ-A-2024-10-25".tagPrefixAndStamp) == ("ZZZ-A", "2024-10-25"))
    #expect(try #require("ZZZ-A-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ-A", "2024-10-25.01"))
    #expect("ZZZ-A-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func test_EmbeddedPeriod() throws {
    #expect(try #require("ZZZ.A-2024-10-25".tagPrefixAndStamp) == ("ZZZ.A", "2024-10-25"))
    #expect(try #require("ZZZ.A-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ.A", "2024-10-25.01"))
    #expect("ZZZ.A-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func test_MultipleEmbeddedHyphen() throws {
    #expect(try #require("ZZZ-A-B-2024-10-25".tagPrefixAndStamp) == ("ZZZ-A-B", "2024-10-25"))
    #expect(
      try #require("ZZZ-A-B-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ-A-B", "2024-10-25.01"))
    #expect("ZZZ-A-B-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func test_MultipleEmbeddedPeriod() throws {
    #expect(try #require("ZZZ.A.B-2024-10-25".tagPrefixAndStamp) == ("ZZZ.A.B", "2024-10-25"))
    #expect(
      try #require("ZZZ.A.B-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ.A.B", "2024-10-25.01"))
    #expect("ZZZ.A.B-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func leadingHyphen() throws {
    #expect(try #require("-ZZZ-2024-10-25".tagPrefixAndStamp) == ("-ZZZ", "2024-10-25"))
    #expect(try #require("-ZZZ-2024-10-25.01".tagPrefixAndStamp) == ("-ZZZ", "2024-10-25.01"))
    #expect("-ZZZ-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func doubleTrailingHyphen() throws {
    #expect(try #require("ZZZ--2024-10-25".tagPrefixAndStamp) == ("ZZZ-", "2024-10-25"))
    #expect(try #require("ZZZ--2024-10-25.01".tagPrefixAndStamp) == ("ZZZ-", "2024-10-25.01"))
    #expect("ZZZ--2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func tripleTrailingHyphen() throws {
    #expect(try #require("ZZZ---2024-10-25".tagPrefixAndStamp) == ("ZZZ--", "2024-10-25"))
    #expect(try #require("ZZZ---2024-10-25.01".tagPrefixAndStamp) == ("ZZZ--", "2024-10-25.01"))
    #expect("ZZZ---2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func leadingPeriod() throws {
    #expect(try #require(".ZZZ-2024-10-25".tagPrefixAndStamp) == (".ZZZ", "2024-10-25"))
    #expect(try #require(".ZZZ-2024-10-25.01".tagPrefixAndStamp) == (".ZZZ", "2024-10-25.01"))
    #expect(".ZZZ-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func doubleTrailingPeriod() throws {
    #expect(try #require("ZZZ..-2024-10-25".tagPrefixAndStamp) == ("ZZZ..", "2024-10-25"))
    #expect(try #require("ZZZ..-2024-10-25.01".tagPrefixAndStamp) == ("ZZZ..", "2024-10-25.01"))
    #expect("ZZZ..-2024-10-25-empty".tagPrefixAndStamp == nil)
  }

  @Test func weirdPrefixes() throws {
    #expect(try #require(".-2024-10-25".tagPrefixAndStamp) == (".", "2024-10-25"))
    #expect(try #require("..-2024-10-25".tagPrefixAndStamp) == ("..", "2024-10-25"))
    #expect(try #require("--2024-10-25.01".tagPrefixAndStamp) == ("-", "2024-10-25.01"))
    #expect(try #require("---2024-10-25.01".tagPrefixAndStamp) == ("--", "2024-10-25.01"))
  }

  @Test func noPrefix() throws {
    #expect("-2024-10-25".tagPrefixAndStamp == nil)
    #expect("2024-10-25".tagPrefixAndStamp == nil)
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

  @Test func appendInvalid() throws {
    #expect("-2024-12-05".appendToPrefix(appendix: "x") == nil)
  }

  @Test func appendNonConforming() throws {
    #expect("xxxxx".appendToPrefix(appendix: "x") == nil)
  }

  @Test func append() throws {
    #expect("tag-2024-12-05".appendToPrefix(appendix: "x") == "tag.x-2024-12-05")
  }

  @Test func bad() throws {
    #expect("iTunes-2024-05-12-empty.01-empty".tagPrefixAndStamp == nil)
  }
}
