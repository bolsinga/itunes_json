//
//  Array+TagFilter.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/7/25.
//

import Foundation

extension Array where Element == StructuredTag {
  fileprivate var stampOrderedMatching: [Element] {
    self.reduce(into: [String: [Element]]()) {
      var tags = $0[$1.stamp] ?? []
      tags.append($1)
      $0[$1.stamp] = tags
    }.compactMap { $0.value.sorted().last }.sorted()
  }
}

extension Array where Element == String {
  var stampOrderedMatching: [Element] {
    self.compactMap { $0.structuredTag }.stampOrderedMatching.map { $0.description }
  }
}
