//
//  QuoteEscaped.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

@propertyWrapper
struct QuoteEscaped: Hashable {
  var wrappedValue: String

  var projectedValue: String {
    "'\(wrappedValue.replacingOccurrences(of: "'", with: "''"))'"
  }
}
