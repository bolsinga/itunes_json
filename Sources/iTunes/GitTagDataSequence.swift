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

struct GitTagDataSequence: AsyncSequence {
  typealias Element = Data

  let git: Git
  let tags: [String]
  let fileName: String

  init(directory: URL, tagPrefix: String, fileName: String) async throws {
    self.git = Git(directory: directory, suppressStandardErr: true)
    try await self.git.status()
    self.tags = try await self.git.tags().matchingFormattedTag(prefix: tagPrefix).sorted()
    self.fileName = fileName
  }

  struct AsyncIterator: AsyncIteratorProtocol {
    let git: Git
    let tags: [String]
    let fileName: String

    var index = 0

    mutating func next() async throws -> Data? {
      guard !Task.isCancelled else { return nil }

      guard index < tags.count else { return nil }

      let tag = tags[index]

      Logger.gitTagData.info("tag: \(tag)")

      let data = try await git.show(commit: tag, path: fileName)

      index += 1

      return data
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
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
