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
  /// Transform the query rows into [Track] and output as JSON
  case tracks
  /// print the raw result rows to stdout.
  case raw
}

extension Transform: EnumerableFlag {}

extension Transform {
  fileprivate func query(
    _ query: String, configuration: GitTagData.Configuration, schemaOptions: SchemaOptions
  )
    async throws
  {
    switch self {
    case .tracks:
      try await GitTagData(configuration: configuration).uniqueTracks(
        query: query, schemaOptions: schemaOptions
      ).forEach {
        print($0.tag)
        print(try $0.item.jsonData().asUTF8String())
      }
    case .raw:
      try await GitTagData(configuration: configuration).printOutput(
        query: query, schemaOptions: schemaOptions)
    }
  }
}

extension GitTagData {
  fileprivate func rowOutput(query: String, schemaOptions: SchemaOptions) async throws -> [Tag<
    [String]
  >] {
    try await transformRows(query: query, schemaOptions: schemaOptions) { queryRows in
      queryRows.flatMap { rows in
        let columnNames = rows[0].map { $0.column }.joined(separator: "|")
        let output = rows.map { $0.map { "\($0.value)" }.joined(separator: "|") }
        return [columnNames] + output
      }
    }
  }

  fileprivate func printOutput(query: String, schemaOptions: SchemaOptions) async throws {
    let lines = try await rowOutput(query: query, schemaOptions: schemaOptions).sorted(by: {
      $0.tag < $1.tag
    }).flatMap {
      let tag = $0.tag
      return $0.item.map { "\(tag)|\($0)" }
    }
    lines.forEach { print($0) }
  }
}

struct QueryCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  static let configuration = CommandConfiguration(
    commandName: "query",
    abstract: "Query sql databases from a git repository.",
    version: iTunesVersion
  )

  /// Transform type.
  @Flag(help: "How to transform the query result.") var transform: Transform = .raw

  /// Lax database schema table constraints.
  @Flag(help: "Lax database schema table constraints")
  var laxSchema: [SchemaFlag] = []

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

  func run() async throws {
    let configuration = GitTagData.Configuration(directory: gitDirectory, fileName: Self.fileName)
    try await transform.query(
      query, configuration: configuration, schemaOptions: laxSchema.schemaOptions)
  }
}
