//
//  SortableName.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct SortableName: Codable, Equatable, Hashable, Sendable {
  let name: String
  let sorted: String

  init(name: String = "", sorted: String = "") {
    self.name = name
    self.sorted = (name != sorted) ? sorted : ""
  }
}

extension SortableName: Comparable {
  private var sort: String {
    !sorted.isEmpty ? sorted : name
  }

  static func < (lhs: SortableName, rhs: SortableName) -> Bool {
    lhs.sort < rhs.sort
  }
}

extension SortableName: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
