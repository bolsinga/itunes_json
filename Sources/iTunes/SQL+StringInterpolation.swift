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
  mutating func _appendInterpolation(_ string: String, options: SQLStringOptions) {
    let literal =
      options.contains(.quoteEscaped) ? string.replacingOccurrences(of: "'", with: "''") : string

    guard !options.contains(.quoted) else {
      appendLiteral("'")
      appendLiteral(literal)
      appendLiteral("'")
      return
    }

    appendLiteral(literal)
  }

  mutating func appendInterpolation(_ number: UInt, options: SQLStringOptions) {
    _appendInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(_ string: String, options: SQLStringOptions) {
    _appendInterpolation(string, options: options)
  }
}
