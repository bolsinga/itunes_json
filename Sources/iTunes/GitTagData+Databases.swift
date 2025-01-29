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

extension DatabaseContext {
  fileprivate func append(tag: String) -> DatabaseContext {
    guard let loggingToken else { return self }
    return DatabaseContext(
      storage: storage, schemaOptions: schemaOptions, loggingToken: "\(loggingToken)-\(tag)")
  }
}

extension GitTagData {
  fileprivate func databases(_ context: DatabaseContext) async throws -> [Tag<Database>] {
    try await transformTracks {
      try await $1.database(context.append(tag: $0))
    }
  }

  fileprivate func rows(query: String, context: DatabaseContext) async throws -> [Tag<
    [[Database.Row]]
  >] {
    var taggedDBs = try await databases(context)

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
    query: String, context: DatabaseContext, transform: @escaping ([[Database.Row]]) throws -> T
  ) async throws -> [Tag<T>] {
    try await rows(query: query, context: context).filter { !$0.item.isEmpty }.map {
      Tag(tag: $0.tag, item: try transform($0.item))
    }
  }
}
