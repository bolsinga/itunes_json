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
    #expect("ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ.X"))
    #expect(!"ZZZ-2024-10-25".matchingFormattedTag(prefix: "X.ZZZ"))
  }

  @Test func test_VersionFormat() throws {
    #expect("ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ.X"))
    #expect(!"ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "X.ZZZ"))
  }

  @Test func test_EmptyFormat() throws {
    #expect(!"ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ.X"))
    #expect(!"ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "X.ZZZ"))
  }

  @Test func test_VersionEmptyFormat() throws {
    #expect(!"ZZZ-2024-10-25.02-empty".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10-25.02-empty".matchingFormattedTag(prefix: "ZZZ.X"))
    #expect(!"ZZZ-2024-10-25.02-empty".matchingFormattedTag(prefix: "X.ZZZ"))
  }

  @Test func test_RandomFormat() throws {
    #expect(!"ZZZ-2024".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ.2024".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ.2024.10".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024-10.25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ-2024.10.25".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func test_TrailingHyphen() throws {
    #expect(!"ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ-"))
    #expect(!"ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ-"))
    #expect(!"ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ-"))
  }

  @Test func test_TrailingPeriod() throws {
    #expect(!"ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ."))
    #expect(!"ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ."))
    #expect(!"ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ."))
  }

  @Test func test_EmbeddedHyphen() throws {
    #expect("ZZZ-A-2024-10-25".matchingFormattedTag(prefix: "ZZZ-A"))
    #expect("ZZZ-A-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ-A"))
    #expect(!"ZZZ-A-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ-A"))
  }

  @Test func test_EmbeddedPeriod() throws {
    #expect("ZZZ.A-2024-10-25".matchingFormattedTag(prefix: "ZZZ.A"))
    #expect("ZZZ.A-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ.A"))
    #expect(!"ZZZ.A-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ.A"))
  }

  @Test func test_MultipleEmbeddedHyphen() throws {
    #expect("ZZZ-A-B-2024-10-25".matchingFormattedTag(prefix: "ZZZ-A-B"))
    #expect("ZZZ-A-B-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ-A-B"))
    #expect(!"ZZZ-A-B-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ-A-B"))
  }

  @Test func test_MultipleEmbeddedPeriod() throws {
    #expect("ZZZ.A.B-2024-10-25".matchingFormattedTag(prefix: "ZZZ.A.B"))
    #expect("ZZZ.A.B-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ.A.B"))
    #expect(!"ZZZ.A.B-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ.A.B"))
  }

  @Test func leadingHyphen() throws {
    #expect("-ZZZ-2024-10-25".matchingFormattedTag(prefix: "-ZZZ"))
    #expect("-ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "-ZZZ"))
    #expect(!"-ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "-ZZZ"))

    #expect(!"-ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"-ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"-ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func doubleTrailingHyphen() throws {
    #expect("ZZZ--2024-10-25".matchingFormattedTag(prefix: "ZZZ-"))
    #expect("ZZZ--2024-10-25.01".matchingFormattedTag(prefix: "ZZZ-"))
    #expect(!"ZZZ--2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ-"))

    #expect(!"ZZZ--2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ--2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ--2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func tripleTrailingHyphen() throws {
    #expect("ZZZ---2024-10-25".matchingFormattedTag(prefix: "ZZZ--"))
    #expect("ZZZ---2024-10-25.01".matchingFormattedTag(prefix: "ZZZ--"))
    #expect(!"ZZZ---2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ--"))

    #expect(!"ZZZ---2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ---2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ---2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func leadingPeriod() throws {
    #expect(".ZZZ-2024-10-25".matchingFormattedTag(prefix: ".ZZZ"))
    #expect(".ZZZ-2024-10-25.01".matchingFormattedTag(prefix: ".ZZZ"))
    #expect(!".ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: ".ZZZ"))

    #expect(!".ZZZ-2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!".ZZZ-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!".ZZZ-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func doubleTrailingPeriod() throws {
    #expect("ZZZ..-2024-10-25".matchingFormattedTag(prefix: "ZZZ.."))
    #expect("ZZZ..-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ.."))
    #expect(!"ZZZ..-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ.."))

    #expect(!"ZZZ..-2024-10-25".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ..-2024-10-25.01".matchingFormattedTag(prefix: "ZZZ"))
    #expect(!"ZZZ..-2024-10-25-empty".matchingFormattedTag(prefix: "ZZZ"))
  }

  @Test func weirdPrefixes() throws {
    #expect(".-2024-10-25".matchingFormattedTag(prefix: "."))
    #expect("..-2024-10-25".matchingFormattedTag(prefix: ".."))
    #expect("--2024-10-25.01".matchingFormattedTag(prefix: "-"))
    #expect("---2024-10-25.01".matchingFormattedTag(prefix: "--"))
  }

  @Test func noPrefix() throws {
    #expect(!"-2024-10-25".matchingFormattedTag(prefix: ""))
    #expect(!"2024-10-25".matchingFormattedTag(prefix: ""))
  }
}
