//
//  String+GitNames.swift
//
//
//  Created by Greg Bolsinga on 4/1/24.
//

import Foundation

extension String {
  var emptyTag: String {
    return self + "-empty"
  }

  fileprivate func appendValue(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.minimumIntegerDigits = 2
    guard let r = formatter.string(from: value as NSNumber) else { return self }
    return self + "." + r
  }

  var nextTag: String {
    let parts = self.components(separatedBy: ".")

    switch parts.count {
    case 1:
      return self.appendValue(1)
    case 2:
      guard let index = Int(parts[1]) else { return self }
      return parts[0].appendValue(index + 1)
    default:
      return self
    }
  }
}
