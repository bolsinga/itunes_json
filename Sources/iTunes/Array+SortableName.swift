//
//  Array+SortableName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/14/24.
//

import Foundation

extension Array where Element == SortableName {
  func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(self)
  }

  func sqlData() throws -> Data {
    try SortableNamesSQLSourceEncoder().encode(self)
  }

  func database(file: URL) async throws {
    var encoder: SortableNamesDBEncoder?
    do {
      encoder = try SortableNamesDBEncoder(
        file: file, tableBuilder: SortableNamesTableBuilder(rows: self))
      try await encoder?.encode()
      await encoder?.close()
    } catch {
      await encoder?.close()
      throw error
    }
  }
}
