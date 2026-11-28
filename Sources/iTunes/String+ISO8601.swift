//
//  String+ISO8601.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation

extension String {
  /// The date of an ISO 8601 string. `Date.formatted(.iso8601)` writes every date of a snapshot as
  /// `2025-03-01T10:21:22Z`, and that form is read without a formatter, because making an
  /// `ISO8601DateFormatter` for each of the dates of 1,700 snapshots takes hours. Any other form
  /// is read by `ISO8601DateFormatter`.
  var iso8601Date: Date? {
    let fast = utf8.withContiguousStorageIfAvailable { Self.fastISO8601Seconds($0) }
    if let fast, let seconds = fast { return Date(timeIntervalSince1970: TimeInterval(seconds)) }
    return ISO8601DateFormatter().date(from: self)
  }

  /// The seconds since 1970 of `YYYY-MM-DDTHH:MM:SSZ`, or nil if the text is not in that form or
  /// is not a date.
  private static func fastISO8601Seconds(_ bytes: UnsafeBufferPointer<UInt8>) -> Int? {
    guard bytes.count == 20, bytes[4] == 45, bytes[7] == 45, bytes[10] == 84, bytes[13] == 58,
      bytes[16] == 58, bytes[19] == 90
    else { return nil }

    func number(_ range: Range<Int>) -> Int? {
      var value = 0
      for index in range {
        let digit = Int(bytes[index]) - 48
        guard (0...9).contains(digit) else { return nil }
        value = value * 10 + digit
      }
      return value
    }

    guard let year = number(0..<4), let month = number(5..<7), let day = number(8..<10),
      let hour = number(11..<13), let minute = number(14..<16), let second = number(17..<19),
      (1...12).contains(month), hour < 24, minute < 60, second < 60
    else { return nil }

    let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    let monthLengths = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    guard (1...monthLengths[month - 1]).contains(day) else { return nil }

    // Days since 1970-01-01 of a date of the proleptic Gregorian calendar.
    let shiftedYear = month <= 2 ? year - 1 : year
    let era = shiftedYear / 400
    let yearOfEra = shiftedYear - era * 400
    let dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1
    let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
    let days = era * 146097 + dayOfEra - 719468
    return days * 86400 + hour * 3600 + minute * 60 + second
  }
}
