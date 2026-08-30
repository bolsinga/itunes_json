//
//  QueryCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

import ArgumentParser
import Foundation

/// Enum representing how the SQL query result should be transformed.
enum Transform: CaseIterable {
  /// Transform the query rows from a normalized database into [Track] and output as JSON
  case tracks
  /// print the raw result rows from a normalized database to stdout.
  case raw
  /// print the raw result from a flat database to stdout.
  case flat
}

extension Transform: EnumerableFlag {}

private enum TransformContext {
  case tracks(DatabaseContext)
  case raw(DatabaseFormat)
}

extension TransformContext {
  fileprivate func query(_ query: String, repository: Repository) async throws {
    switch self {
    case .tracks(let context):
      try await repository.uniqueTracks(query: query, format: DatabaseFormat.normalized(context))
        .forEach {
          print($0.tag)
          print(try $0.item.jsonData().asUTF8String())
        }
    case .raw(let format):
      try await repository.printOutput(query: query, format: format)
    }
  }
}

extension Repository {
  fileprivate func rowOutput(query: String, format: DatabaseFormat) async throws -> [Tag<[String]>]
  {
    try await transformRows(query: query, format: format) {
      $0.flatMap { rows in
        guard !rows.isEmpty else { return [String]() }
        let columnNames = rows[0].map { $0.column }.joined(separator: "|")
        let output = rows.map { $0.map { "\($0.value)" }.joined(separator: "|") }
        return [columnNames] + output
      }
    }.reduce(into: [Tag<[String]>]()) {
      $0.append($1)
    }
  }

  fileprivate func printOutput(query: String, format: DatabaseFormat) async throws {
    let lines = try await rowOutput(query: query, format: format).sorted(by: {
      $0.tag < $1.tag
    }).flatMap {
      let tag = $0.tag
      return $0.item.map { "\(tag)|\($0)" }
    }
    lines.forEach { print($0) }
  }
}

struct QueryCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "query",
    abstract: "Query sql databases from a git repository.",
    version: iTunesVersion
  )

  /// Transform type.
  @Flag(help: "How to transform the query result.") var transform: Transform = .raw

  /// Lax normalized database schema table constraints.
  @Flag(help: "Lax normalized database schema table constraints")
  var laxSchema: [SchemaFlag] = []

  /// Should query run serially.
  @Flag(
    help:
      "Run the query on each database serially. Some SQL may ATTACH a single database, so this would be required."
  ) var serializeDatabaseQueries: Bool = false

  @OptionGroup var repositoryArguments: RepositoryArguments
  var repository: Repository { repositoryArguments.repository }

  @Argument(help: "The SQL query to run.") var query: String = ""

  func validate() throws {
    if query.isEmpty {
      throw ValidationError("Please provide a query to run against the database.")
    }
  }

  fileprivate var context: TransformContext {
    let context = DatabaseContext(
      storage: .memory, schemaOptions: laxSchema.schemaOptions, loggingToken: "query",
      serializeDatabaseQueries: serializeDatabaseQueries)
    switch transform {
    case .tracks:
      return .tracks(context)
    case .raw:
      return .raw(.normalized(context))
    case .flat:
      return .raw(
        .flat(
          FlatTracksDatabaseContext(
            storage: .memory, loggingToken: "query",
            serializeDatabaseQueries: serializeDatabaseQueries)))
    }
  }

  func run() async throws {
    try await context.query(query, repository: repository)
  }
}
