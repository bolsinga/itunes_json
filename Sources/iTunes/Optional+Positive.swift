//
//  Optional+Positive.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation

extension Optional where Wrapped == Int {
  /// The number if it is greater than zero. Zero and negative numbers are as unusable as an absent one.
  var positive: Int? {
    guard let self, self > 0 else { return nil }
    return self
  }
}
