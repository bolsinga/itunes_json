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
    case persistentID(UInt)
    case dateAdded(Date?)
    case composer(String?)

    static func < (lhs: IdentifierCorrection.Property, rhs: IdentifierCorrection.Property) -> Bool {
      switch (lhs, rhs) {
      case (.duration(let lhv), .duration(let rhv)):
        return lhv < rhv
      case (.persistentID(let lhv), .persistentID(let rhv)):
        return lhv < rhv
      case (.dateAdded(let lhv), .dateAdded(let rhv)):
        return lhv < rhv
      case (.composer(let lhv), .composer(let rhv)):
        return lhv < rhv
      default:
        return false
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
