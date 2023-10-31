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

extension Source {
  func gather() async throws -> [Track] {
    switch self {
    case .itunes:
      return try Track.gatherAllTracks()
    case .musickit:
      return try await Track.gatherWithMusicKit()
    }
  }
}

extension Track {
  static private func jsonData(_ source: Source) async throws -> Data {
    let tracks = try await source.gather()

    guard tracks.count > 0 else {
      throw TrackExportError.noITunesTracks
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    return try encoder.encode(tracks)
  }

  static public func export(to url: URL, source: Source) async throws {
    let jsonData = try await Track.jsonData(source)
    try jsonData.write(to: url, options: .atomic)
  }

  static public func jsonString(_ source: Source) async throws -> String {
    let jsonData = try await Track.jsonData(source)

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw TrackExportError.cannotConvertJSONToString
    }
    return jsonString
  }
}
