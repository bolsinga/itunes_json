//
//  RepositoryArguments.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 8/23/26.
//

import ArgumentParser
import Foundation

struct RepositoryArguments: ParsableArguments {
  /// Git Directory to read and write data from.
  @Option(
    help: "The path for the git directory to work with.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return Repository(directory: url)
    })
  )
  var repository: Repository
}
