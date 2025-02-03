//
//  Optional+Comparable.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/2/25.
//

extension Optional where Wrapped: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    if let lhs, let rhs {
      return lhs < rhs
    }
    return lhs == nil && rhs == nil
  }
}
