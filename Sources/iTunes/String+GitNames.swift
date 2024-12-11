//
//  String+GitNames.swift
//
//
//  Created by Greg Bolsinga on 4/1/24.
//

import Foundation

extension String {
  static let emptySuffix = "-empty"

  var emptyTag: String {
    return self + Self.emptySuffix
  }

  fileprivate static func twoDigits(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.minimumIntegerDigits = 2
    guard let r = formatter.string(from: value as NSNumber) else { return "" }
    return r
  }

  fileprivate func appendValue(_ value: Int) -> String {
    return self + ".\(Self.twoDigits(value))"
  }

  var nextTag: String {
    let parts = self.components(separatedBy: ".")

    switch parts.count {
    case 1:
      return self.appendValue(1)
    case 2...Int.max:
      guard let lastPart = parts.last else {
        return self
      }
      guard let value = Int(lastPart) else {
        return self.appendValue(1)
      }
      return self.replacingOccurrences(of: lastPart, with: Self.twoDigits(value + 1))
    default:
      return self
    }
  }
}
