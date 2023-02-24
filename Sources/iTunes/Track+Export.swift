//
//  Track+Export.swift
//
//
//  Created by Greg Bolsinga on 10/16/22.
//

import Foundation

enum TrackExportError: Error {
  case noITunesTracks
  case cannotConvertJSONToString
}

extension Track {
  static private func jsonData() throws -> Data {
    let tracks = try Track.gatherAllTracks()

    guard tracks.count > 0 else {
      throw TrackExportError.noITunesTracks
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    return try encoder.encode(tracks)
  }

  static public func export(_ directoryURL: URL) throws {
    let jsonData = try Track.jsonData()

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())

    let url = directoryURL.appending(path: "iTunes-\(dateString).json")
    try jsonData.write(to: url, options: .atomic)
  }

  static public func jsonString() throws -> String {
    let jsonData = try Track.jsonData()

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw TrackExportError.cannotConvertJSONToString
    }
    return jsonString
  }
}
