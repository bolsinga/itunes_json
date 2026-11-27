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
  /// The largest shift of an unchanged date that is read as the quirk. The history of the author's
  /// library has shifts of 1 to 3 hours of play dates and 1 to 4 hours of dates added.
  static let quirkLimit: TimeInterval = 4 * 60 * 60

  /// Compares two dates, reading a difference of a whole number of hours, from 1 to 4, as
  /// `orderedSameQuirk`. Daylight saving time and the shifts that come with it move an unchanged
  /// date by whole hours. A larger difference is too likely to be a real change.
  func compareQuirk(_ other: Date) -> DateQuirkComparisonResult {
    let distance = abs(self.distance(to: other))
    guard
      distance == 0 || distance > Self.quirkLimit
        || distance.truncatingRemainder(dividingBy: 60 * 60) != 0
    else {
      return .orderedSameQuirk
    }

    return self.compare(other).dateQuirkComparisonResult
  }
}
