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
  fileprivate static let quoteEscaped = SQLStringOptions(rawValue: 1 << 1)
}

extension String.StringInterpolation {
  mutating func _appendInterpolation(_ string: String, sqlOptions: SQLStringOptions) {
    let literal =
      sqlOptions.contains(.quoteEscaped) ? string.replacingOccurrences(of: "'", with: "''") : string

    guard !sqlOptions.contains(.quoted) else {
      appendLiteral("'")
      appendLiteral(literal)
      appendLiteral("'")
      return
    }

    appendLiteral(literal)
  }

  mutating func appendInterpolation(_ number: UInt, sqlOptions: SQLStringOptions) {
    _appendInterpolation(String(number), sqlOptions: sqlOptions)
  }

  mutating func appendInterpolation(_ string: String, sqlOptions: SQLStringOptions) {
    _appendInterpolation(string, sqlOptions: sqlOptions.union(.quoteEscaped))
  }
}
