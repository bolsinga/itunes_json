//
//  Track+Export.swift
//
//
//  Created by Greg Bolsinga on 10/16/22.
//

import Foundation
import iTunes

enum TrackExportError: Error {
  case cannotConvertJSONToString
}

extension Track {
  static public func export(to url: URL, tracks: [Track]) throws {
    let jsonData = try tracks.data()
    try jsonData.write(to: url, options: .atomic)
  }

  static public func jsonString(_ tracks: [Track]) throws -> String {
    let jsonData = try tracks.data()

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw TrackExportError.cannotConvertJSONToString
    }
    return jsonString
  }
}
