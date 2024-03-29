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

extension DefaultStringInterpolation {
  static var SQLBindable: Bool = false

  mutating private func appendSQLInterpolation(_ string: String, options: SQLStringOptions) {
    guard !Self.SQLBindable else {
      appendLiteral("?")
      return
    }

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

  mutating func appendInterpolation(sql number: UInt, options: SQLStringOptions = []) {
    appendSQLInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(sql number: Int, options: SQLStringOptions = []) {
    appendSQLInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(sql number: UInt64, options: SQLStringOptions = []) {
    appendSQLInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(sql string: String, options: SQLStringOptions = []) {
    appendSQLInterpolation(string, options: options)
  }
}
