//
//  TimeTest.swift
//
//
//  Created by Greg Bolsinga on 1/15/24.
//

import Carbon
import Foundation

private let validTime = "2004-02-04T23:32:22Z"
private let validTimestamp = Double(1_075_937_542)
private let invalidTime = "2004-02-05T00:32:22Z"
private let invalidTimestamp = Double(1_075_941_142)
private let json = """
  { "v" : "2004-02-04T23:32:22Z", "i" : "2004-02-05T00:32:22Z" }
  """.data(using: .utf8)!

private enum TimeTestError: Error {
  case parseValidError
  case parseInvalidError
  case bothError

  case jsonParseValidError
  case jsonParseInvalidError
  case jsonBothError

  case chetAtkinsMissing
  case chetAtkinsChanged

  var result: Int {
    switch self {
    case .parseValidError:
      return 1
    case .parseInvalidError:
      return 2
    case .bothError:
      return 3
    case .jsonParseValidError:
      return 4
    case .jsonParseInvalidError:
      return 5
    case .jsonBothError:
      return 6
    case .chetAtkinsMissing:
      return 7
    case .chetAtkinsChanged:
      return 8
    }
  }
}

private struct S: Decodable {
  let v: Date?
  let i: Date?
}

public func testTime() async -> Int {
  var result = 0
  do {
    try await validateTimeParsing()
  } catch {
    if let tError = error as? TimeTestError {
      result = tError.result
    } else {
      result = 100
    }
  }
  return result
}

private func validateTimeParsing() async throws {
  let validDate = ISO8601DateFormatter().date(from: validTime)

  let parseValidDate = validDate?.timeIntervalSince1970 == validTimestamp

  let invalidDate = ISO8601DateFormatter().date(from: invalidTime)

  let parseInvalidDate = invalidDate?.timeIntervalSince1970 == invalidTimestamp

  if !parseValidDate || !parseInvalidDate {
    if !parseValidDate && !parseInvalidDate {
      throw TimeTestError.bothError
    }
    if !parseValidDate {
      throw TimeTestError.parseValidError
    }
    throw TimeTestError.parseInvalidError
  }

  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601

  let s = try decoder.decode(S.self, from: json)

  let jsonParseValidDate = s.v == validDate

  let jsonParseInvalidDate = s.i == invalidDate

  if !jsonParseValidDate || !jsonParseInvalidDate {
    if !jsonParseValidDate && !jsonParseInvalidDate {
      throw TimeTestError.jsonBothError
    }
    if !jsonParseValidDate {
      throw TimeTestError.jsonParseValidError
    }
    throw TimeTestError.jsonParseInvalidError
  }

  let chetAtkinsYesterday = try await Source.itunes.gather(nil, repair: nil).filter {
    $0.persistentID == 17_859_820_717_873_205_520
  }
  if chetAtkinsYesterday.isEmpty {
    throw TimeTestError.chetAtkinsMissing
  }
  let chetAtkinsYesterdayExpectedDate = chetAtkinsYesterday.first!.playDateUTC == validDate
  if !chetAtkinsYesterdayExpectedDate {
    throw TimeTestError.chetAtkinsChanged
  }
}
