//
//  Track+Export.swift
//
//
//  Created by Greg Bolsinga on 10/16/22.
//

import Foundation
import iTunes

enum TrackExportError: Error {
  case noITunesTracks
  case cannotConvertJSONToString
}

extension Track {
  static private func jsonData(_ tracks: [Track]) throws -> Data {
    guard tracks.count > 0 else {
      throw TrackExportError.noITunesTracks
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    return try encoder.encode(tracks)
  }

  static public func export(to url: URL, tracks: [Track]) throws {
    let jsonData = try Track.jsonData(tracks)
    try jsonData.write(to: url, options: .atomic)
  }

  static public func jsonString(_ tracks: [Track]) throws -> String {
    let jsonData = try Track.jsonData(tracks)

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw TrackExportError.cannotConvertJSONToString
    }
    return jsonString
  }
}
