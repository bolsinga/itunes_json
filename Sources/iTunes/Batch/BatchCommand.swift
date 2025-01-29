//
//  BatchMusic.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import ArgumentParser
import Foundation

extension Batch: EnumerableFlag {}

struct BatchCommand: AsyncParsableCommand {
  private static let fileName = "itunes.json"

  static let configuration = CommandConfiguration(
    commandName: "batch",
    abstract: "Create many sql source or databases from a git repository.",
    version: iTunesVersion
  )

  /// Batch type.
  @Flag(help: "Batch type to build.") var batch: Batch = .sql

  /// Lax normalized database schema table constraints.
  @Flag(help: "Lax normalized database schema table constraints")
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

  /// Output Directory for batch results.
  @Option(
    help:
      "The path at which to create the output file.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var outputDirectory: URL

  func run() async throws {
    let configuration = GitTagData.Configuration(directory: gitDirectory, fileName: Self.fileName)
    try await batch.build(
      configuration, outputDirectory: outputDirectory,
      schemaOptions: laxSchema.schemaOptions)
  }
}
