//
//  QueryCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

import ArgumentParser
import Foundation

extension GitTagData {
  func sortedRows(query: String, schemaOptions: SchemaOptions) async throws
    -> [Tag<[[Database.Row]]>]
  {
    try await rows(query: query, schemaOptions: schemaOptions).sorted(by: { $0.tag < $1.tag })
  }

  func transformRows<T: Sendable>(
    query: String, schemaOptions: SchemaOptions, transform: @escaping ([[Database.Row]]) throws -> T
  ) async throws -> [Tag<T>] {
    try await sortedRows(query: query, schemaOptions: schemaOptions).filter { !$0.item.isEmpty }.map
    {
      Tag(tag: $0.tag, item: try transform($0.item))
    }
  }

  func rowOutput(query: String, schemaOptions: SchemaOptions) async throws -> [Tag<[String]>] {
    try await transformRows(query: query, schemaOptions: schemaOptions) { queryRows in
      queryRows.flatMap { rows in
        let columnNames = rows[0].map { $0.column }.joined(separator: "|")
        let output = rows.map { $0.map { "\($0.value)" }.joined(separator: "|") }
        return [columnNames] + output
      }
    }
  }

  func printOutput(query: String, schemaOptions: SchemaOptions) async throws {
    let lines = try await rowOutput(query: query, schemaOptions: schemaOptions).flatMap {
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
    try await GitTagData(configuration: configuration).printOutput(
      query: query, schemaOptions: laxSchema.schemaOptions)
  }
}
