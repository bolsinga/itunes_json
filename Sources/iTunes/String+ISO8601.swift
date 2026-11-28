//
//  String+ISO8601.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation

extension String {
  /// The style that `Date.formatted(.iso8601)` writes the dates of a snapshot with. One is kept,
  /// because making an `ISO8601DateFormatter` for each date of each track takes hours for the
  /// history, and sharing one of those is only about 3 times faster. A style is a value, and it
  /// reads a date in about 0.3 microseconds.
  private static let iso8601Style = Date.ISO8601FormatStyle()

  /// The date of an ISO 8601 string, nil if it is not one.
  var iso8601Date: Date? {
    try? Self.iso8601Style.parse(self)
  }
}
