//
//  QueryCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

import ArgumentParser
import Foundation

extension Database {
  func executeAndClose(_ query: String) throws -> [[Row]] {
    let result = try execute(query: query)
    close()
    return result
  }
}

extension GitTagData {
  func execute(query: String, schemaOptions: SchemaOptions) async throws {
    let databases = try await transformTracks {
      let database: Database = try await $1.database(
        storage: .memory, loggingToken: "batch-\($0)", schemaOptions: schemaOptions)
      return database
    }.sorted(by: { $0.tag < $1.tag })

    for database in databases {
      let queryRows = try await database.item.executeAndClose(query)
      guard !queryRows.isEmpty else { continue }

      for rows in queryRows {
        if rows.isEmpty { continue }

        var columns = [String]()
        if columns.isEmpty {
          columns = rows[0].keys.sorted()
          print((["tag"] + columns).joined(separator: "|"))
        }

        for row in rows {
          let rowDescription = columns.reduce(into: [database.tag]) {
            $0.append("\(row[$1] ?? .null)")
          }.joined(separator: "|")
          print(rowDescription)
        }
      }
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
