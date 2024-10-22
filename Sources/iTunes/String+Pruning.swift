//
//  String+Pruning.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 10/22/24.
//

import Foundation

extension String {
  func uniqueNonEmptyString(_ other: String?) -> String? {
    (self == other) ? nil : self.nonEmptyString
  }

  var nonEmptyString: String? {
    self.isEmpty ? nil : self
  }
}
