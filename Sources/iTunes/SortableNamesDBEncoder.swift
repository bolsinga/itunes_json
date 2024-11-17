//
//  SortableNamesDBEncoder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/16/24.
//

import Foundation

struct SortableNamesDBEncoder {
  private let db: Database
  private let tableBuilder: SortableNamesTableBuilder

  init(file: URL, tableBuilder: SortableNamesTableBuilder) throws {
    self.db = try Database(file: file, loggingToken: nil)
    self.tableBuilder = tableBuilder
  }

  @discardableResult
  func encode() async throws -> [SortableName: Int64] {
    let result = try await db.createTable(tableBuilder, schemaConstraints: .strict)
    for sql in tableBuilder.dropStatements { try await db.execute(sql) }
    return result
  }

  func close() async {
    await db.close()
  }
}
