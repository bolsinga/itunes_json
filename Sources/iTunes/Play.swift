//
//  Play.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation
import os

extension Logger {
  fileprivate static let playCompare = Logger(category: "play.compare")
}

struct Play: Codable, Comparable, Hashable, Sendable {
  let date: Date?
  let count: Int?

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.date == rhs.date {
      return lhs.count < rhs.count
    }
    return lhs.date < rhs.date
  }
}

extension Track {
  var play: Play { Play(date: playDateUTC, count: playCount) }
}

private enum Check {
  /// The Play is good to use.
  case good

  /// They are duplicates.
  case duplicate

  /// The count is not increasing, and the date is increasing. This looks like when iTunes forgets the count, so use the Date and the associated count value
  case updateCount(Int)

  /// The Play is invalid; cannot determine what may be fixed.
  case invalid
}

private enum DateComparisonResult {
  case orderedAscending
  case orderedSame
  case orderedSameQuirk
  case orderedDescending
}

extension ComparisonResult {
  fileprivate var dateComparisonResult: DateComparisonResult {
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
  fileprivate func compareQuirk(_ other: Date) -> DateComparisonResult {
    guard abs(self.distance(to: other)).truncatingRemainder(dividingBy: 60 * 60) != 0 else {
      return .orderedSameQuirk
    }

    return self.compare(other).dateComparisonResult
  }
}

private enum PlayComparisonResult {
  case orderedAscending
  case orderedSame
  case orderedSameQuirk
  case orderedDescending

  case invalid
}

extension DateComparisonResult {
  fileprivate var playComparisonResult: PlayComparisonResult {
    switch self {
    case .orderedAscending:
      return .orderedAscending
    case .orderedSame:
      return .orderedSame
    case .orderedSameQuirk:
      return .orderedSameQuirk
    case .orderedDescending:
      return .orderedDescending
    }
  }
}

extension Play {
  fileprivate var isValid: Bool {
    date != nil && count != nil
  }

  private func compareDate(_ other: Play) -> PlayComparisonResult {
    switch (self.date, other.date) {
    case (.some(let sDate), .some(let oDate)):
      return sDate.compareQuirk(oDate).playComparisonResult
    default:
      return .invalid
    }
  }

  private func compareCount(_ other: Play) -> PlayComparisonResult {
    switch (self.count, other.count) {
    case (.some(let sCount), .some(let oCount)):
      let difference = sCount - oCount
      if difference == 0 { return .orderedSame }
      return difference < 1 ? .orderedAscending : .orderedDescending
    default:
      return .invalid
    }
  }

  private func compare(_ other: Play) -> (
    overall: PlayComparisonResult, date: PlayComparisonResult, count: PlayComparisonResult
  ) {
    let dateCompare = compareDate(other)
    let countCompare = compareCount(other)

    if dateCompare == countCompare {
      return (dateCompare, dateCompare, countCompare)
    }

    if dateCompare == .orderedSameQuirk && countCompare == .orderedSame {
      return (.orderedSameQuirk, dateCompare, countCompare)
    }

    return (.invalid, dateCompare, countCompare)
  }

  private func check(_ other: Play) -> Check {
    let (comparison, dateCompare, countCompare) = self.compare(other)

    switch comparison {
    case .orderedAscending:
      return .good
    case .orderedSame, .orderedSameQuirk:
      return .duplicate
    case .orderedDescending:
      Logger.playCompare.info("Descending")
      return .invalid
    case .invalid:
      switch (dateCompare, countCompare) {
      case (.orderedDescending, .orderedAscending):
        /// The Play has a Date earlier than its self (which is not DST shifted).
        Logger.playCompare.info("Date Descending, Count Ascending")
        return .invalid
      case (.orderedAscending, .orderedDescending):
        guard let count else {
          Logger.playCompare.info("Date Ascending, Count Descending, No Self Count")
          return .invalid
        }
        let countIncrease = (other.count != nil && other.count! != 0) ? other.count! : 1
        return .updateCount(count + countIncrease)
      case (.orderedAscending, .invalid):
        guard let count else {
          Logger.playCompare.info("Date Ascending, Count Invalid, No Self Count")
          return .invalid
        }
        return .updateCount(count + 1)
      case (.orderedSame, .orderedDescending), (.orderedSameQuirk, .orderedDescending):
        guard count != nil, let otherCount = other.count, otherCount == 0 else {
          Logger.playCompare.info(
            "Date Same, Count Descending, Other Count: \(String(describing: other.count))")
          return .invalid
        }
        return .duplicate
      default:
        guard isValid, !other.isValid else {
          Logger.playCompare.info("Both Invalid")
          return .invalid
        }
        return .duplicate
      }
    }
  }

  fileprivate func normalize(_ other: Play) -> Play? {
    switch check(other) {
    case .good:
      return other
    case .duplicate:
      return self
    case .updateCount(let count):
      return Play(date: other.date, count: count)
    case .invalid:
      return nil
    }
  }
}

extension Array where Element == Play {
  func normalize() -> [Element] {
    return self.reduce(into: [Element]()) { partialResult, item in
      guard let mostRecent = partialResult.last, mostRecent.isValid else {
        partialResult.append(item)
        return
      }
      guard let next = mostRecent.normalize(item) else { return }
      partialResult.append(next)
    }
  }
}
