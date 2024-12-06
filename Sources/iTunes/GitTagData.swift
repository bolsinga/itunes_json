//
//  GitTagData.swift
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

public struct TagData: Sendable {
  let tag: String
  let data: Data
}

public struct GitTagData {
  public struct Configuration {
    let directory: URL
    let tagPrefix: String
    let fileName: String

    public init(directory: URL, tagPrefix: String = "", fileName: String) {
      self.directory = directory
      self.tagPrefix = tagPrefix
      self.fileName = fileName
    }
  }

  private let configuration: Configuration
  private let git: Git

  public init(configuration: Configuration) throws {
    self.configuration = configuration
    self.git = Git(directory: configuration.directory, suppressStandardErr: true)
  }

  private struct ReadSequence: AsyncSequence {
    typealias Element = TagData

    let git: Git
    let tags: [String]
    let fileName: String

    init(git: Git, tagPrefix: String, fileName: String) async throws {
      self.git = git
      self.tags = try await self.git.tags().filter { $0.matchingFormattedTag(prefix: tagPrefix) }
        .sorted()
      self.fileName = fileName
    }

    struct AsyncIterator: AsyncIteratorProtocol {
      let git: Git
      let tags: [String]
      let fileName: String

      var index = 0

      mutating public func next() async throws -> TagData? {
        guard !Task.isCancelled else { return nil }

        guard index < tags.count else { return nil }

        let tag = tags[index]

        Logger.gitTagData.info("tag: \(tag)")

        let data = try await git.show(commit: tag, path: fileName)

        index += 1

        return TagData(tag: tag, data: data)
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      AsyncIterator(git: git, tags: tags, fileName: fileName)
    }
  }

  func tagDatum() async throws -> [TagData] {
    try await self.git.status()

    var tagDatum: [TagData] = []
    for try await tagData in try await ReadSequence(
      git: git, tagPrefix: configuration.tagPrefix, fileName: configuration.fileName)
    {
      tagDatum.append(tagData)
    }
    return tagDatum
  }
}
