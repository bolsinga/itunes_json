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
    let taggedRows = try await rows(query: query, schemaOptions: schemaOptions).sorted(by: {
      $0.tag < $1.tag
    })

    for taggedRow in taggedRows {
      let queryRows = taggedRow.item
      guard !queryRows.isEmpty else { continue }

      for rows in queryRows {
        if rows.isEmpty { continue }

        var columns = [String]()
        if columns.isEmpty {
          columns = rows[0].map { $0.column }
          print((["tag"] + columns).joined(separator: "|"))
        }

        for row in rows {
          let rowDescription = ([taggedRow.tag] + row.map { "\($0.value)" }).joined(separator: "|")
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
    try await GitTagData(configuration: configuration).execute(
      query: query, schemaOptions: laxSchema.schemaOptions)
  }
}
