//
//  DateQuirkTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation
import Testing

@testable import iTunes

struct DateQuirkTests {
  let date = Date(timeIntervalSince1970: 1_700_000_000)

  @Test func exactlyOneHourEitherWayIsTheQuirk() {
    #expect(date.compareQuirk(date.advanced(by: 3600)) == .orderedSameQuirk)
    #expect(date.compareQuirk(date.advanced(by: -3600)) == .orderedSameQuirk)
  }

  @Test func sameDateIsSame() {
    #expect(date.compareQuirk(date) == .orderedSame)
  }

  @Test func otherDifferencesAreOrdered() {
    #expect(date.compareQuirk(date.advanced(by: 3601)) == .orderedAscending)
    #expect(date.compareQuirk(date.advanced(by: 2 * 3600)) == .orderedAscending)
    #expect(date.compareQuirk(date.advanced(by: 24 * 3600)) == .orderedAscending)
    #expect(date.compareQuirk(date.advanced(by: -2 * 3600)) == .orderedDescending)
    #expect(date.compareQuirk(date.advanced(by: -365 * 24 * 3600)) == .orderedDescending)
  }
}
