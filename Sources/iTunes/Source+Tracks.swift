//
//  Source+Tracks.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Source {
  public func gather(_ source: String?) async throws -> [Track] {
    switch self {
    case .itunes:
      return try Track.gatherAllTracks()
    case .musickit:
      return try await Track.gatherWithMusicKit()
    case .jsonString:
      return try Track.createFromString(source)
    case .xmlJsonString:
      return try XMLTrack.createFromString(source)
    }
  }

  public func reExport(_ source: String?) throws {
    let tracks = try XMLTrack._createFromString(source)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(tracks)

    print("\(try data.asUTF8String())")
  }
}
