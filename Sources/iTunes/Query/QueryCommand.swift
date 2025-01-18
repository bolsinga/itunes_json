//
//  QueryCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

import ArgumentParser
import Foundation

extension GitTagData {
  func execute(query: String, schemaOptions: SchemaOptions) async throws {
    let databases = try await transformTracks {
      let database: Database = try await $1.database(
        storage: .memory, loggingToken: "batch-\($0)", schemaOptions: schemaOptions)
      return database
    }

    for database in databases {
      print(database.tag)
      try await database.item.execute(query)
      await database.item.close()
    }
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

  @Flag(help: "How to filter git tags.")
  var tagFilter: TagFilter = .ordered

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

  @Option(help: "The prefix to use for the git tags.") var tagPrefix: String = "iTunes"

  @Argument(help: "The SQL query to run.") var query: String = ""

  func validate() throws {
    if query.isEmpty {
      throw ValidationError("Please provide a query to run against the database.")
    }
  }

  func run() async throws {
    let configuration = GitTagData.Configuration(
      directory: gitDirectory, tagPrefix: tagPrefix, fileName: Self.fileName, tagFilter: tagFilter)
    try await GitTagData(configuration: configuration).execute(
      query: query, schemaOptions: laxSchema.schemaOptions)
  }
}
