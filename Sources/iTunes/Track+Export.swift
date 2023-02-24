//
//  Track+Export.swift
//
//
//  Created by Greg Bolsinga on 10/16/22.
//

import Foundation

public struct TrackExportError: Error, CustomStringConvertible {
  public internal(set) var message: String

  /// Creates a new validation error with the given message.
  public init(_ message: String) {
    self.message = message
  }

  public var description: String {
    message
  }
}

extension Track {
  static private func jsonData() throws -> Data {
    guard let tracks = try? Track.gatherAllTracks() else {
      throw TrackExportError("Cannot get tracks from iTunes")
    }

    guard tracks.count > 0 else {
      throw TrackExportError("No JSON to record")
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    guard let jsonData = try? encoder.encode(tracks) else {
      throw TrackExportError("Unable to create JSON for \(tracks)")
    }

    return jsonData
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
      throw TrackExportError("Unable to create JSON string")
    }
    return jsonString
  }
}
