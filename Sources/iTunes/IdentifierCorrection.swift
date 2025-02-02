//
//  IdentifierCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/2/25.
//

import Foundation

struct IdentifierCorrection: Codable, Comparable, Hashable, Sendable {
  enum Property: Codable, Comparable, Hashable, Sendable {
    case duration(Int?)

    static func < (lhs: IdentifierCorrection.Property, rhs: IdentifierCorrection.Property) -> Bool {
      switch (lhs, rhs) {
      case (.duration(let lhv), .duration(let rhv)):
        return lhv < rhv
      }
    }
  }

  let persistentID: UInt
  let correction: Property

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.persistentID == rhs.persistentID {
      return lhs.correction < rhs.correction
    }
    return lhs.persistentID < rhs.persistentID
  }
}

extension IdentifierCorrection: CustomStringConvertible {
  var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
