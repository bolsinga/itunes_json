//
//  TagListExtractionTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/7/25.
//

import Testing

@testable import iTunes

struct TagListExtractionTests {
  @Test func justPrefixes() async throws {
    let tags = """
      iTunes-V12-2025-01-05
      iTunes-V12-2025-01-05.01
      iTunes-V12-2025-01-06
      iTunes-V12-2025-01-06-empty
      iTunes-V12-2025-01-06.01
      iTunes-V12-2025-01-07-empty
      """.split(separator: "\n").map { String($0) }

    #expect(!tags.isEmpty)
    #expect(tags.count == 6)

    let result = tags.shuffled().orderedMatching(tagPrefix: "iTunes-V12")

    #expect(result.count == 4)

    #expect(result[0] == tags[0])
    #expect(result[1] == tags[1])
    #expect(result[2] == tags[2])
    #expect(result[3] == tags[4])
  }

  @Test func assortedPrefixes_ordered() async throws {
    let tags = """
      iTunes-2006-01-01
      iTunes.artists-2006-01-01
      iTunes-V2-2006-01-01
      iTunes-V3-2006-01-01
      iTunes-V4-2006-01-01
      iTunes-V5-2006-01-01
      iTunes-V6-2006-02-01
      iTunes-V7-2006-03-01
      iTunes-V8-2006-04-01
      iTunes-V9-2006-05-01
      iTunes-V10-2006-05-01
      iTunes-V11-2006-05-01
      iTunes-V12-2006-05-01
      iTunes-V12-2006-06-01
      """.split(separator: "\n").map { String($0) }

    #expect(!tags.isEmpty)
    #expect(tags.count == 14)

    let result = tags.shuffled().orderedMatching(tagPrefix: "iTunes-V12")

    #expect(result.count == 2)

    for index in 0..<result.count {
      #expect(result[index] == tags[index + 12])
    }
  }

  @Test func assortedPrefixes_date() async throws {
    let tags = """
      iTunes-2006-01-01
      iTunes.artists-2006-01-01
      iTunes-V2-2006-01-01
      iTunes-V3-2006-01-01
      iTunes-V4-2006-01-01
      iTunes-V5-2006-01-01
      iTunes-V6-2006-02-01
      iTunes-V7-2006-03-01
      iTunes-V8-2006-04-01
      iTunes-V9-2006-05-01
      iTunes-V10-2006-05-01
      iTunes-V11-2006-05-01
      iTunes-V12-2006-05-01
      iTunes-V12-2006-06-01
      """.split(separator: "\n").map { String($0) }

    #expect(!tags.isEmpty)
    #expect(tags.count == 14)

    let result = tags.shuffled().orderedMatching(tagPrefix: "iTunes-V12")

    #expect(!(result.count == 9))  // go all the way back to V5 (since it is the earliest encoded Date.

    for index in 0..<result.count {
      #expect(!(result[index] == tags[index + 5]))
    }
  }
}
