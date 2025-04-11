//
//  URL+Databases.swift
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

extension FlatTracksDatabaseContext {
  fileprivate func append(tag: String) -> FlatTracksDatabaseContext {
    guard let loggingToken else { return self }
    return FlatTracksDatabaseContext(storage: storage, loggingToken: "\(loggingToken)-\(tag)")
  }
}

extension DatabaseFormat {
  fileprivate func append(tag: String) -> DatabaseFormat {
    switch self {
    case .normalized(let context):
      .normalized(context.append(tag: tag))
    case .flat(let context):
      .flat(context.append(tag: tag))
    }
  }
}

extension URL {
  func databases(_ format: DatabaseFormat) -> AsyncThrowingStream<Tag<Database>, any Error> {
    transformTracks {
      try await format.append(tag: $0).database(tracks: $1)
    }
  }

  fileprivate func serializedDatabaseQueryRows(query: String, format: DatabaseFormat)
    -> AsyncThrowingStream<Tag<[[Database.Row]]>, any Error>
  {
    let (stream, continuation) = AsyncThrowingStream<Tag<[[Database.Row]]>, any Error>.makeStream()
    Task.detached {
      defer { continuation.finish() }
      do {
        for taggedDB in try await databases(format).reduce(
          into: [Tag<Database>](), { $0.append($1) }
        ).sorted(by: { $0.tag < $1.tag }) {
          continuation.yield(try await taggedDB.execute(query: query))
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    return stream
  }

  fileprivate func databaseQueryRows(query: String, format: DatabaseFormat) -> AsyncThrowingStream<
    Tag<[[Database.Row]]>, any Error
  > {
    let (stream, continuation) = AsyncThrowingStream<Tag<[[Database.Row]]>, any Error>.makeStream()
    Task.detached {
      defer { continuation.finish() }
      do {
        for try await taggedDB in databases(format) {
          continuation.yield(try await taggedDB.execute(query: query))
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }
    return stream
  }

  fileprivate func rows(query: String, format: DatabaseFormat) -> some AsyncSequence<
    Tag<[[Database.Row]]>, any Error
  > {
    if format.serializeDatabaseQueries {
      return serializedDatabaseQueryRows(query: query, format: format)
    } else {
      return databaseQueryRows(query: query, format: format)
    }
  }

  func transformRows<T: Sendable>(
    query: String, format: DatabaseFormat,
    transform: @escaping @Sendable ([[Database.Row]]) throws -> T
  ) -> some AsyncSequence<Tag<T>, any Error> {
    rows(query: query, format: format).filter { !$0.item.isEmpty }.map {
      Tag(tag: $0.tag, item: try transform($0.item))
    }
  }
}
