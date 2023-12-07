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
    let data = try tracks.data()
    try data.write(to: url, options: .atomic)
  }

  static public func jsonString(_ tracks: [Track]) throws -> String {
    let data = try tracks.data()

    guard let s = String(data: data, encoding: .utf8) else {
      throw TrackExportError.cannotConvertJSONToString
    }
    return s
  }
}
