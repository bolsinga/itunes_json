//
//  BatchMusic.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/6/24.
//

import ArgumentParser
import Foundation
import iTunes

let fileName = "itunes.json"

extension Batch: EnumerableFlag {}

@main
struct BatchMusic: AsyncParsableCommand {
  /// Batch type.
  @Flag(help: "Batch type to build.") var batch: Batch = .sql

  /// Database schema constraints.
  @Flag(help: "Database schema constraints.")
  var schemaConstraints: SchemaConstraints = .strict

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

  public func run() async throws {
    let configuration = GitTagData.Configuration(
      directory: gitDirectory, tagPrefix: tagPrefix, fileName: fileName)
    try await batch.build(
      configuration, outputDirectory: outputDirectory, schemaConstraints: schemaConstraints)
  }
}
