//
//  QueryCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

import ArgumentParser
import Foundation
import GitLibrary

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
  fileprivate func query(_ query: String, backupFile: URL) async throws {
    switch self {
    case .tracks(let context):
      let git = Implementation.outOfProcess(
        directory: backupFile.parentDirectory, suppressStandardErr: true
      ).create()

      return try await git.uniqueTracks(
        query: query, format: DatabaseFormat.normalized(context), filename: backupFile.filename
      )
      .forEach {
        print($0.tag)
        print(try $0.item.jsonData().asUTF8String())
      }
    case .raw(let format):
      return try await backupFile.printOutput(query: query, format: format)
    }
  }
}

extension URL {
  fileprivate func rowOutput(query: String, format: DatabaseFormat) async throws -> [Tag<[String]>]
  {
    let git = Implementation.outOfProcess(
      directory: self.parentDirectory, suppressStandardErr: true
    ).create()

    return try await git.transformRows(query: query, format: format, filename: self.filename) {
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

  /// Git Directory to read and write data from.
  @Option(
    help: "The path for the git directory to work with.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var gitDirectory: URL

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
    try await context.query(query, backupFile: gitDirectory.backupFile)
  }
}
