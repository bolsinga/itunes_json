//
//  BatchMusic.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import ArgumentParser
import Foundation
import GitLibrary

extension Batch: EnumerableFlag {}

struct BatchCommand: AsyncParsableCommand {
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

  @OptionGroup var repositoryArguments: RepositoryArguments
  var repository: Repository { repositoryArguments.repository }

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
    try await batch.build(
      outputDirectory: outputDirectory,
      repository: repository,
      schemaOptions: laxSchema.schemaOptions)
  }
}
