//
//  SQL+StringInterpolation.swift
//
//
//  Created by Greg Bolsinga on 1/3/24.
//

import Foundation

struct SQLStringOptions: OptionSet {
  let rawValue: Int

  static let quoteEscaped = SQLStringOptions(rawValue: 1 << 0)
}

extension DefaultStringInterpolation {
  static var SQLBindable: Bool = false

  mutating private func appendSQLInterpolation(_ string: String, options: SQLStringOptions) {
    guard !Self.SQLBindable else {
      appendLiteral("?")
      return
    }

    guard options.contains(.quoteEscaped) else {
      appendLiteral(string)
      return
    }

    appendLiteral("'")
    appendLiteral(string.replacingOccurrences(of: "'", with: "''"))
    appendLiteral("'")
  }

  mutating func appendInterpolation(sql number: UInt, options: SQLStringOptions = []) {
    appendSQLInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(sql number: Int, options: SQLStringOptions = []) {
    appendSQLInterpolation(String(number), options: options)
  }

  mutating func appendInterpolation(sql string: String, options: SQLStringOptions = []) {
    appendSQLInterpolation(string, options: options)
  }
}
