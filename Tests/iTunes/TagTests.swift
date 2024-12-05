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
    #expect(["ZZZ-2024-10-25"].matchingFormattedTag(prefix: "ZZZ").count == 1)
    #expect(["ZZZ-2024-10-25"].matchingFormattedTag(prefix: "ZZZ.X").count == 0)
    #expect(["ZZZ-2024-10-25"].matchingFormattedTag(prefix: "X.ZZZ").count == 0)
  }

  @Test func test_VersionFormat() throws {
    #expect(["ZZZ-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ").count == 1)
    #expect(["ZZZ-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ.X").count == 0)
    #expect(["ZZZ-2024-10-25.01"].matchingFormattedTag(prefix: "X.ZZZ").count == 0)
  }

  @Test func test_EmptyFormat() throws {
    #expect(["ZZZ-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ.X").count == 0)
    #expect(["ZZZ-2024-10-25-empty"].matchingFormattedTag(prefix: "X.ZZZ").count == 0)
  }

  @Test func test_VersionEmptyFormat() throws {
    #expect(["ZZZ-2024-10-25.02-empty"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ-2024-10-25.02-empty"].matchingFormattedTag(prefix: "ZZZ.X").count == 0)
    #expect(["ZZZ-2024-10-25.02-empty"].matchingFormattedTag(prefix: "X.ZZZ").count == 0)
  }

  @Test func test_RandomFormat() throws {
    #expect(["ZZZ-2024"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ.2024"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ-2024-10"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ.2024.10"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ-2024-10.25"].matchingFormattedTag(prefix: "ZZZ").count == 0)
    #expect(["ZZZ-2024.10.25"].matchingFormattedTag(prefix: "ZZZ").count == 0)
  }

  @Test func test_TrailingHyphen() throws {
    #expect(["ZZZ-2024-10-25"].matchingFormattedTag(prefix: "ZZZ-").count == 0)
    #expect(["ZZZ-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ-").count == 0)
    #expect(["ZZZ-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ-").count == 0)
  }

  @Test func test_TrailingPeriod() throws {
    #expect(["ZZZ-2024-10-25"].matchingFormattedTag(prefix: "ZZZ.").count == 0)
    #expect(["ZZZ-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ.").count == 0)
    #expect(["ZZZ-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ.").count == 0)
  }

  @Test func test_EmbeddedHyphen() throws {
    #expect(["ZZZ-A-2024-10-25"].matchingFormattedTag(prefix: "ZZZ-A").count == 1)
    #expect(["ZZZ-A-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ-A").count == 1)
    #expect(["ZZZ-A-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ-A").count == 0)
  }

  @Test func test_EmbeddedPeriod() throws {
    #expect(["ZZZ.A-2024-10-25"].matchingFormattedTag(prefix: "ZZZ.A").count == 1)
    #expect(["ZZZ.A-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ.A").count == 1)
    #expect(["ZZZ.A-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ.A").count == 0)
  }

  @Test func test_MultipleEmbeddedHyphen() throws {
    #expect(["ZZZ-A-B-2024-10-25"].matchingFormattedTag(prefix: "ZZZ-A-B").count == 1)
    #expect(["ZZZ-A-B-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ-A-B").count == 1)
    #expect(["ZZZ-A-B-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ-A-B").count == 0)
  }

  @Test func test_MultipleEmbeddedPeriod() throws {
    #expect(["ZZZ.A.B-2024-10-25"].matchingFormattedTag(prefix: "ZZZ.A.B").count == 1)
    #expect(["ZZZ.A.B-2024-10-25.01"].matchingFormattedTag(prefix: "ZZZ.A.B").count == 1)
    #expect(["ZZZ.A.B-2024-10-25-empty"].matchingFormattedTag(prefix: "ZZZ.A.B").count == 0)
  }
}
