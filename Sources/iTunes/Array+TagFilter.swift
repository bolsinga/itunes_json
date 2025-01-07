//
//  Array+TagFilter.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/7/25.
//

import Foundation

extension Array where Element == String {
  func orderedMatching(tagPrefix: String) -> [String] {
    self.filter { $0.matchingFormattedTag(prefix: tagPrefix) }.sorted()
  }
}
