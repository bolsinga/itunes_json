//
//  Track+RequiredValues.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation

/// Tracks that have no value for a number every database row needs.
struct MissingValuesError: Error, CustomStringConvertible {
  struct Entry: Equatable {
    let persistentID: UInt
    let name: String
    let fields: [String]
  }

  let entries: [Entry]

  var description: String {
    let shown = entries.prefix(10).map {
      "\($0.persistentID) \"\($0.name)\": no \($0.fields.joined(separator: ", "))"
    }
    let rest = entries.count > 10 ? ["... and \(entries.count - 10) more"] : []
    return (["\(entries.count) track(s) are missing a required value."] + shown + rest).joined(
      separator: "\n")
  }
}

extension Track {
  /// The required numbers this track does not have. Absent, zero and negative numbers are missing.
  var missingRequiredFields: [String] {
    [
      ("track number", trackNumber), ("track count", trackCount), ("year", year),
      ("duration", totalTime),
    ].filter { $0.1.positive == nil }.map { $0.0 }
  }

  func requiredNumber(_ keyPath: KeyPath<Track, Int?>) throws -> Int {
    guard let number = self[keyPath: keyPath].positive else {
      throw MissingValuesError(entries: [missingEntry])
    }
    return number
  }

  private var missingEntry: MissingValuesError.Entry {
    MissingValuesError.Entry(persistentID: persistentID, name: name, fields: missingRequiredFields)
  }
}

extension Array where Element == Track {
  /// Throws if any track is missing a required number, naming every such track.
  func requireCompleteNumbers() throws {
    let entries = self.filter { !$0.missingRequiredFields.isEmpty }.map {
      MissingValuesError.Entry(
        persistentID: $0.persistentID, name: $0.name, fields: $0.missingRequiredFields)
    }
    if !entries.isEmpty { throw MissingValuesError(entries: entries) }
  }
}
