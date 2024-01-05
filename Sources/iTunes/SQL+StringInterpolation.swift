//
//  SQL+StringInterpolation.swift
//
//
//  Created by Greg Bolsinga on 1/3/24.
//

import Foundation

struct SQLStringOptions: OptionSet {
  let rawValue: Int

  static let quoted = SQLStringOptions(rawValue: 1 << 0)
  static let quoteEscaped = SQLStringOptions(rawValue: 1 << 1)

  static let safeQuoted: SQLStringOptions = [.quoted, .quoteEscaped]
}

extension String.StringInterpolation {
  mutating func _appendInterpolation(_ string: String, sql: SQLStringOptions) {
    let literal =
      sql.contains(.quoteEscaped) ? string.replacingOccurrences(of: "'", with: "''") : string

    guard !sql.contains(.quoted) else {
      appendLiteral("'")
      appendLiteral(literal)
      appendLiteral("'")
      return
    }

    appendLiteral(literal)
  }

  mutating func appendInterpolation(_ number: UInt, sql: SQLStringOptions) {
    _appendInterpolation(String(number), sql: sql)
  }

  mutating func appendInterpolation(_ string: String, sql: SQLStringOptions) {
    _appendInterpolation(string, sql: sql)
  }
}
