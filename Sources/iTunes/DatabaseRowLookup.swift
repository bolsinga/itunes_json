//
//  DatabaseRowLookup.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

typealias DatabaseRowLookup = [String: Database.Value]

extension DatabaseRowLookup {
  init(row: Database.Row) {
    self.init(uniqueKeysWithValues: row)
  }

  func string(_ key: String) -> String? {
    guard let s = self[key]?.string, !s.isEmpty else { return nil }
    return s
  }

  func integer(_ key: String) -> Int? {
    guard let i = self[key]?.integer else { return nil }
    return Int(i)
  }

  func boolean(_ key: String) -> Bool? {
    guard let v = integer(key) else { return nil }
    guard v == 1 else { return nil }
    return true
  }

  func date(_ key: String) -> Date? {
    guard let v = string(key) else { return nil }
    return ISO8601DateFormatter().date(from: v)
  }
}
