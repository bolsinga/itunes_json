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

  @Test func standardTagVersion() async throws {
    #expect(try #require("iTunes-V1".tagVersion) == ("iTunes", 1))
    #expect(try #require("iTunes.V1".tagVersion) == ("iTunes", 1))
    #expect(try #require("iTunes-V10".tagVersion) == ("iTunes", 10))
    #expect(try #require("iTunes.V10".tagVersion) == ("iTunes", 10))
    #expect(try #require("iTunes-V100".tagVersion) == ("iTunes", 100))
    #expect(try #require("iTunes.V100".tagVersion) == ("iTunes", 100))
    #expect(try #require("iTunes-V1000".tagVersion) == ("iTunes", 1000))
    #expect(try #require("iTunes.V1000".tagVersion) == ("iTunes", 1000))
    #expect(try #require("iTunes-A10".tagVersion) == ("iTunes", 10))
    #expect(try #require("iTunes.A10".tagVersion) == ("iTunes", 10))
    #expect(try #require("iTunes-A100".tagVersion) == ("iTunes", 100))
    #expect(try #require("iTunes.A100".tagVersion) == ("iTunes", 100))
    #expect(try #require("iTunes-A1000".tagVersion) == ("iTunes", 1000))
    #expect(try #require("iTunes.A1000".tagVersion) == ("iTunes", 1000))
    #expect(try #require("iTunes.artists1".tagVersion) == ("iTunes", 1))
  }

  @Test func invalidTagVersion() async throws {
    #expect("iTunes".tagVersion == nil)
    #expect("iTunes1".tagVersion == nil)
    #expect("iTunes.1".tagVersion == nil)
    #expect("iTunes-1".tagVersion == nil)
    #expect("iTunesV1".tagVersion == nil)
    #expect("iTunes.A".tagVersion == nil)
    #expect("iTunes-A".tagVersion == nil)
    #expect("iTunes.1A".tagVersion == nil)
    #expect("iTunes-1A".tagVersion == nil)
    #expect("iTunes.1artists".tagVersion == nil)
  }

  @Test func fullVersion() async throws {
    #expect(
      try #require("iTunes-V10-2025-01-07".structuredTag)
        == StructuredTag(root: "iTunes", version: 10, stamp: "2025-01-07"))
    #expect(
      try #require("iTunes-V10-2025-01-07.01".structuredTag)
        == StructuredTag(root: "iTunes", version: 10, stamp: "2025-01-07.01"))
    #expect(
      try #require("iTunes-V100-2025-01-07.01".structuredTag)
        == StructuredTag(root: "iTunes", version: 100, stamp: "2025-01-07.01"))
    #expect(
      try #require("iTunes-V1000-2025-01-07.01".structuredTag)
        == StructuredTag(root: "iTunes", version: 1000, stamp: "2025-01-07.01"))
    #expect("iTunes-V10-2025-01-07.empty".structuredTag == nil)
    #expect("iTunes.artists-2025-01-07".structuredTag == nil)
    #expect("iTunes-2006-01-01".structuredTag == nil)
  }

  @Test func nextVersion() async throws {
    #expect(
      StructuredTag(root: "R", version: 3, stamp: "2025-01-20").next
        == StructuredTag(root: "R", version: 4, stamp: "2025-01-20"))
    #expect(
      StructuredTag(root: "R", version: 10, stamp: "2025-01-20").next
        == StructuredTag(root: "R", version: 11, stamp: "2025-01-20"))
    #expect(
      StructuredTag(root: "R", version: 100, stamp: "2025-01-20").next
        == StructuredTag(root: "R", version: 101, stamp: "2025-01-20"))
  }
}
