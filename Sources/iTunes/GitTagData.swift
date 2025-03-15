//
//  GitTagData.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import GitLibrary
import os

extension Logger {
  fileprivate static let gitTagData = Logger(category: "gitTagData")
}

extension URL {
  private static var backupFileName: String { "itunes.json" }

  var configuration: GitTagData.Configuration {
    GitTagData.Configuration(file: self.appending(path: Self.backupFileName))
  }
}

extension Git {
  func addAndTag(fileName: String, tag tagName: String, version: String) async throws {
    try await add(fileName)

    let hasChanges = await {
      do {
        try await diff()
        Logger.gitTagData.info("Empty Tag: \(tagName)")
        return false
      } catch {
        return true
      }
    }()

    if hasChanges {
      try await commit("\(tagName)\n\(version)")
    }
    try await tag(tagName)
  }
}

extension Tag where Item == Data {
  fileprivate func add(to git: Git, file: URL, version: String) async throws {
    Logger.gitTagData.info("Add: \(tag)")

    // this makes memory shoot up, unexpectedly.
    try item.write(to: file)

    try await git.addAndTag(fileName: file.lastPathComponent, tag: tag, version: version)
  }
}

struct GitTagData {
  struct Configuration {
    let file: URL
    let limit: Int?

    init(file: URL, limit: Int? = nil) {
      self.file = file
      self.limit = limit
    }

    var directory: URL {
      file.deletingLastPathComponent()
    }

    var fileName: String {
      file.lastPathComponent
    }

    func filter(tags: [String]) -> [String] {
      tags.stampOrderedMatching
    }
  }

  let configuration: Configuration
  private let git: Git

  init(configuration: Configuration) throws {
    self.configuration = configuration
    self.git = Git(directory: configuration.directory, suppressStandardErr: true)
  }

  private struct ReadSequence: AsyncSequence {
    typealias Element = Tag<Data>

    let tags: [String]
    let fileName: String
    let limit: Int?
    /// tag, path
    let dataProvider: (String, String) async throws -> Data

    struct AsyncIterator: AsyncIteratorProtocol {
      let tags: [String]
      let fileName: String
      let limit: Int?
      /// tag, path
      let dataProvider: (String, String) async throws -> Data

      var index = 0

      mutating func next() async throws -> Element? {
        guard !Task.isCancelled else { return nil }

        guard index < tags.count else { return nil }

        if let limit, index == limit { return nil }

        let tag = tags[index]

        Logger.gitTagData.info("tag: \(tag)")

        let data = try await dataProvider(tag, fileName)

        index += 1

        return Element(tag: tag, item: data)
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      AsyncIterator(tags: tags, fileName: fileName, limit: limit, dataProvider: dataProvider)
    }
  }

  func tagDatum() async throws -> [Tag<Data>] {
    try await self.git.status()

    var tagDatum: [Tag<Data>] = []
    for try await tagData in ReadSequence(
      tags: configuration.filter(tags: try await git.tags()), fileName: configuration.fileName,
      limit: configuration.limit,
      dataProvider: {
        try await git.show(commit: $0, path: $1)
      })
    {
      tagDatum.append(tagData)

    }
    return tagDatum
  }

  func write(tagDatum: [Tag<Data>], initialCommit: String, branch: String, version: String)
    async throws
  {
    try await git.status()

    try await git.createBranch(named: branch, initialCommit: initialCommit)

    var tagDatum = tagDatum.sorted(by: { $0.tag > $1.tag })  // latest to oldest.

    for tagData in tagDatum.reversed() {
      tagDatum.removeLast()

      try await tagData.add(to: git, file: configuration.file, version: version)
    }

    //    try await git.push()
    //    try await git.pushTags()
    //    try await git.gc()
  }
}
