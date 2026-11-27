//
//  Date+Quirk.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/22/25.
//

import Foundation

enum DateQuirkComparisonResult {
  case orderedAscending
  case orderedSame
  case orderedSameQuirk
  case orderedDescending
}

extension ComparisonResult {
  fileprivate var dateQuirkComparisonResult: DateQuirkComparisonResult {
    switch self {
    case .orderedAscending:
      return .orderedAscending
    case .orderedSame:
      return .orderedSame
    case .orderedDescending:
      return .orderedDescending
    }
  }
}

extension Date {
  /// Compares two dates, reading a difference of exactly one hour as `orderedSameQuirk`. Daylight
  /// saving time starting or ending moves an unchanged date by that hour, and nothing larger.
  func compareQuirk(_ other: Date) -> DateQuirkComparisonResult {
    guard abs(self.distance(to: other)) != 60 * 60 else {
      return .orderedSameQuirk
    }

    return self.compare(other).dateQuirkComparisonResult
  }
}
