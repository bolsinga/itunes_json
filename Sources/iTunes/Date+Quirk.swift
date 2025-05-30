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
  func compareQuirk(_ other: Date) -> DateQuirkComparisonResult {
    guard abs(self.distance(to: other)).truncatingRemainder(dividingBy: 60 * 60) != 0 else {
      return .orderedSameQuirk
    }

    return self.compare(other).dateQuirkComparisonResult
  }
}
