//
//  GitTagData+Databases.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/24/25.
//

import Foundation
import os

extension Logger {
  fileprivate static let query = Logger(category: "query")
}

extension Database {
  fileprivate func executeAndClose(_ query: String) throws -> [[Row]] {
    let result = try execute(query: query)
    close()
    return result
  }
}

extension GitTagData {
  func databases(schemaOptions: SchemaOptions) async throws -> [Tag<Database>] {
    try await transformTracks {
      let database: Database = try await $1.database(
        storage: .memory, loggingToken: "batch-\($0)", schemaOptions: schemaOptions)
      return database
    }
  }

  func rows(query: String, schemaOptions: SchemaOptions) async throws -> [Tag<[[Database.Row]]>] {
    var taggedDBs = try await databases(schemaOptions: schemaOptions)

    return try await withThrowingTaskGroup(of: Tag<[[Database.Row]]>.self) { group in
      for taggedDB in taggedDBs.reversed() {
        taggedDBs.removeLast()
        group.addTask {
          Logger.query.info("Query Tag: \(taggedDB.tag)")
          return Tag(tag: taggedDB.tag, item: try await taggedDB.item.executeAndClose(query))
        }
      }

      var tags: [Tag<[[Database.Row]]>] = []
      for try await tag in group {
        tags.append(tag)
      }
      return tags
    }
  }
}
