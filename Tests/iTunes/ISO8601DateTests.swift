//
//  ISO8601DateTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation
import Testing

@testable import iTunes

struct ISO8601DateTests {
  private func system(_ string: String) -> Date? {
    ISO8601DateFormatter().date(from: string)
  }

  @Test func theFormTheSnapshotsUseIsReadAsTheSystemFormatterReadsIt() {
    // Every 1,234,567 seconds from 1970 to 2100, which covers leap days and the ends of months.
    for seconds in stride(from: 0, to: 4_102_444_800, by: 1_234_567) {
      let text = Date(timeIntervalSince1970: TimeInterval(seconds)).formatted(.iso8601)
      #expect(text.iso8601Date == system(text), "\(text)")
      #expect(text.iso8601Date == Date(timeIntervalSince1970: TimeInterval(seconds)), "\(text)")
    }
  }

  @Test func edgesAreReadAsTheSystemFormatterReadsThem() {
    for text in [
      "1970-01-01T00:00:00Z", "1999-12-31T23:59:59Z", "2000-02-29T12:00:00Z",
      "2000-03-01T00:00:00Z", "2024-02-29T23:59:59Z", "2100-02-28T23:59:59Z",
      "2100-03-01T00:00:00Z", "2026-11-29T00:00:00Z", "1969-12-31T23:59:59Z",
    ] {
      #expect(text.iso8601Date == system(text), "\(text)")
      #expect(text.iso8601Date != nil, "\(text)")
    }
  }

  @Test func textThatIsNotADateIsNil() {
    for text in [
      "", "none", "2025-13-01T10:21:22Z", "abcd-ef-ghTij:kl:mnZ", "2025-03-01T10:21:22",
      "2025-03-01",
    ] {
      #expect(text.iso8601Date == nil, "\(text)")
    }
  }

  @Test func impossibleDatesAreRolledOverAsTheSystemFormatterRollsThemOver() {
    for text in ["2025-02-29T10:21:22Z", "2025-03-01T24:21:22Z"] {
      #expect(text.iso8601Date == system(text), "\(text)")
      #expect(text.iso8601Date != nil, "\(text)")
    }
  }
}
