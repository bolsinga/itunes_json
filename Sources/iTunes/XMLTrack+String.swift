//
//  XMLTrack+String.swift
//
//
//  Created by Greg Bolsinga on 12/11/23.
//

import Foundation

enum XMLJSONDecodingError: Error {
  case stringEncodingError
}

extension XMLTrack {
  static public func createFromString(_ source: String?) throws -> [Track] {
    let oldTracks = try Self._createFromString(source)
    return oldTracks.map { Track.createFromXMLTrack($0) }
  }

  static func _createFromString(_ source: String?) throws -> [XMLTrack] {
    guard let source else {
      preconditionFailure("Should have been caught during ParsableArguments.validate().")
    }
    guard let data = source.data(using: .utf8) else {
      throw XMLJSONDecodingError.stringEncodingError
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([XMLTrack].self, from: data)
  }
}
