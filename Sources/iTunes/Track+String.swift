//
//  Track+String.swift
//
//
//  Created by Greg Bolsinga on 12/11/23.
//

import Foundation

enum JSONDecodingError: Error {
  case stringEncodingError
}

extension Track {
  static public func createFromString(_ source: String?) throws -> [Track] {
    guard let source else { preconditionFailure("Should have been caught during ParsableArguments.validate().") }
    guard let data = source.data(using: .utf8) else { throw JSONDecodingError.stringEncodingError }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([Track].self, from: data)
  }
}
