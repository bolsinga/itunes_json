//
//  Play.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation

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

  /// The Play has a Date earlier than its self (which is not DST shifted).
  case recedingDate

  /// The count is receding, but the Date is OK.
  case recedingCount

  /// The count is empty. The Date has changed, so the count should reflect at least the associated count value.
  case emptyCount(Int)

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
      return .invalid
    case .invalid:
      switch (dateCompare, countCompare) {
      case (.orderedDescending, .orderedAscending):
        return .recedingDate
      case (.orderedAscending, .orderedDescending):
        guard let count, let otherCount = other.count, otherCount == 0 else {
          return .recedingCount
        }
        return .emptyCount(count + 1)
      case (.orderedAscending, .invalid):
        guard let count else { return .invalid }
        return .emptyCount(count + 1)
      case (.orderedSame, .orderedDescending), (.orderedSameQuirk, .orderedDescending):
        guard count != nil, let otherCount = other.count, otherCount == 0 else {
          return .invalid
        }
        return .duplicate
      default:
        return .invalid
      }
    }
  }

  fileprivate func normalize(_ other: Play) -> Play? {
    switch check(other) {
    case .good:
      return other
    case .duplicate:
      return self
    case .recedingDate:
      return nil
    case .recedingCount:
      return nil
    case .emptyCount(let count):
      return Play(date: other.date, count: count)
    case .invalid:
      return nil
    }
  }
}

extension Array where Element == Play {
  func normalize() -> [Element] {
    guard let first, first.isValid else { return [] }

    return self[1...].reduce(into: [first]) { partialResult, item in
      guard let mostRecent = partialResult.last else { return }
      guard let next = mostRecent.normalize(item) else { return }
      partialResult.append(next)
    }
  }
}
