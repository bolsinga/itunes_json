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

  func sqlData(tableName: String) throws -> Data {
    try SortableNamesSQLSourceEncoder().encode(self, tableName: tableName)
  }

  func database(file: URL, tableName: String) async throws {
    var encoder: SortableNamesDBEncoder?
    do {
      encoder = try SortableNamesDBEncoder(
        file: file, tableBuilder: SortableNamesTableBuilder(rows: self, tableName: tableName))
      try await encoder?.encode()
      await encoder?.close()
    } catch {
      await encoder?.close()
      throw error
    }
  }
}
