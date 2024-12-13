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

struct TagData: Sendable {
  let tag: String
  let data: Data
}

extension TagData {
  fileprivate func add(to git: Git, file: URL) async throws {
    Logger.gitTagData.info("Add: \(tag)")

    // this makes memory shoot up, unexpectedly.
    try data.write(to: file)

    try await git.add(file.lastPathComponent)

    let hasChanges = await {
      do {
        try await git.diff()
        Logger.gitTagData.info("Empty Tag: \(tag)")
        return false
      } catch {
        return true
      }
    }()

    if hasChanges {
      try await git.commit(tag)
      try await git.tag(tag)
    }
  }

  func write(to directory: URL, pathExtension: String) throws {
    Logger.gitTagData.info("Write: \(tag)")

    let url = directory.appending(path: tag).appendingPathExtension(pathExtension)
    try data.write(to: url)
  }
}

extension String {
  fileprivate func replaceTagPrefix(tagPrefix: String) -> String {
    replacePrefix(newPrefix: tagPrefix) ?? "\(self)-Could-Not-Properly-Replace-\(tagPrefix)"
  }
}

extension Array where Element == TagData {
  func replaceTagPrefix(tagPrefix: String) -> [Element] {
    self.map { TagData(tag: $0.tag.replaceTagPrefix(tagPrefix: tagPrefix), data: $0.data) }
  }

  var initialCommit: String? {
    self.sorted(by: { $0.tag < $1.tag }).first?.tag
  }
}

struct GitTagData {
  struct Configuration {
    let directory: URL
    let tagPrefix: String
    let branch: String?
    let fileName: String

    public init(
      directory: URL, tagPrefix: String = "", branch: String? = nil, fileName: String
    ) {
      self.directory = directory
      self.tagPrefix = tagPrefix
      self.branch = branch
      self.fileName = fileName
    }

    var file: URL {
      directory.appending(path: fileName)
    }
  }

  private let configuration: Configuration
  private let git: Git

  init(configuration: Configuration) throws {
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

  func write(tagDatum: [TagData], initialCommit: String) async throws {
    enum WriteError: Error {
      case noBranch
    }

    guard let branch = configuration.branch else { throw WriteError.noBranch }

    try await git.status()

    try await git.createBranch(named: branch, initialCommit: initialCommit)

    var tagDatum = tagDatum.sorted(by: { $0.tag > $1.tag })  // latest to oldest.

    for tagData in tagDatum.reversed() {
      tagDatum.removeLast()

      try await tagData.add(to: git, file: configuration.file)
    }

    //    try await git.push()
    //    try await git.pushTags()
    //    try await git.gc()
  }
}
