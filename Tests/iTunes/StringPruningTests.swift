//
//  StringPruningTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 10/22/24.
//

import Testing

@testable import iTunes

struct StringPruningTests {
  @Test func pruning() async throws {
    var testString: String? = "Greg"
    #expect(testString?.uniqueNonEmptyString(nil) == testString)
    #expect(testString?.uniqueNonEmptyString("") == testString)
    #expect(testString?.uniqueNonEmptyString(testString) == nil)
    #expect(testString?.uniqueNonEmptyString("Oscar") == testString)

    testString = ""
    #expect(testString?.uniqueNonEmptyString(nil) == nil)
    #expect(testString?.uniqueNonEmptyString("") == nil)
    #expect(testString?.uniqueNonEmptyString(testString) == nil)
    #expect(testString?.uniqueNonEmptyString("Oscar") == nil)

    testString = nil
    #expect(testString?.uniqueNonEmptyString(nil) == nil)
    #expect(testString?.uniqueNonEmptyString("") == nil)
    #expect(testString?.uniqueNonEmptyString(testString) == nil)
    #expect(testString?.uniqueNonEmptyString("Oscar") == nil)
  }
}
