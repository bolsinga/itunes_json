//
//  GitTagDataSequence.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let gitTagData = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "gitTagData")
}

public struct GitTagDataSequence: AsyncSequence {
  public typealias Element = Data

  public struct Configuration {
    let directory: URL
    let tagPrefix: String
    let fileName: String

    public init(directory: URL, tagPrefix: String, fileName: String) {
      self.directory = directory
      self.tagPrefix = tagPrefix
      self.fileName = fileName
    }
  }

  let git: Git
  let tags: [String]
  let fileName: String

  public init(configuration: Configuration) async throws {
    self.git = Git(directory: configuration.directory, suppressStandardErr: true)
    try await self.git.status()
    self.tags = try await self.git.tags().matchingFormattedTag(prefix: configuration.tagPrefix)
      .sorted()
    self.fileName = configuration.fileName
  }

  public struct AsyncIterator: AsyncIteratorProtocol {
    let git: Git
    let tags: [String]
    let fileName: String

    var index = 0

    mutating public func next() async throws -> Data? {
      guard !Task.isCancelled else { return nil }

      guard index < tags.count else { return nil }

      let tag = tags[index]

      Logger.gitTagData.info("tag: \(tag)")

      let data = try await git.show(commit: tag, path: fileName)

      index += 1

      return data
    }
  }

  public func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(git: git, tags: tags, fileName: fileName)
  }

  func data() async throws -> [Data] {
    var tagData: [Data] = []
    for try await data in self {
      tagData.append(data)
    }
    return tagData
  }
}
