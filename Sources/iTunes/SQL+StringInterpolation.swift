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
}

extension String.StringInterpolation {
  mutating func appendInterpolation(_ number: UInt, sqlOptions: SQLStringOptions) {
    appendInterpolation(String(number), sqlOptions: sqlOptions)
  }

  mutating func appendInterpolation(_ string: String, sqlOptions: SQLStringOptions) {
    guard !sqlOptions.contains(.quoted) else {
      appendLiteral("'")
      appendLiteral(string)
      appendLiteral("'")
      return
    }

    appendLiteral(string)
  }
}
