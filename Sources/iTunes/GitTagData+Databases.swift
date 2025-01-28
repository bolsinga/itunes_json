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
  fileprivate func executeAndClose(_ query: String, arguments: [Database.Value]) throws -> [[Row]] {
    let result = try execute(query: query, arguments: arguments)
    close()
    return result
  }
}

extension Tag where Item == Database {
  fileprivate func execute(query: String) async throws -> Tag<[[Database.Row]]> {
    Logger.query.info("Query Tag: \(tag)")
    return Tag<[[Database.Row]]>(
      tag: tag, item: try await item.executeAndClose(query, arguments: [.string(tag)]))
  }
}

extension GitTagData {
  func databases(schemaOptions: SchemaOptions) async throws -> [Tag<Database>] {
    try await transformTracks {
      let database: Database = try await $1.database(
        context: Database.Context(storage: .memory, loggingToken: "batch-\($0)"),
        schemaOptions: schemaOptions)
      return database
    }
  }

  func rows(query: String, schemaOptions: SchemaOptions) async throws -> [Tag<[[Database.Row]]>] {
    var taggedDBs = try await databases(schemaOptions: schemaOptions)

    if configuration.serializeDatabaseQueries {
      var tags: [Tag<[[Database.Row]]>] = []
      for taggedDB in taggedDBs.sorted(by: { $0.tag < $1.tag }) {
        tags.append(try await taggedDB.execute(query: query))
      }
      return tags
    } else {
      return try await withThrowingTaskGroup(of: Tag<[[Database.Row]]>.self) { group in
        for taggedDB in taggedDBs.reversed() {
          taggedDBs.removeLast()
          group.addTask {
            try await taggedDB.execute(query: query)
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

  func transformRows<T: Sendable>(
    query: String, schemaOptions: SchemaOptions, transform: @escaping ([[Database.Row]]) throws -> T
  ) async throws -> [Tag<T>] {
    try await rows(query: query, schemaOptions: schemaOptions).filter { !$0.item.isEmpty }.map {
      Tag(tag: $0.tag, item: try transform($0.item))
    }
  }
}
