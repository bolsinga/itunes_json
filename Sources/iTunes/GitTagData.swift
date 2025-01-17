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

struct GitTaggedData: Tagged, Sendable {
  let tag: String
  let data: Data
}

extension GitTaggedData {
  fileprivate func add(to git: Git, file: URL, version: String) async throws {
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
      try await git.commit("\(tag)\n\(version)")
    }
    try await git.tag(tag)
  }
}

extension String {
  fileprivate func replaceTagPrefix(tagPrefix: String) -> String {
    replacePrefix(newPrefix: tagPrefix) ?? "\(self)-Could-Not-Properly-Replace-\(tagPrefix)"
  }
}

extension Array where Element == GitTaggedData {
  func replaceTagPrefix(tagPrefix: String) -> [Element] {
    self.map { GitTaggedData(tag: $0.tag.replaceTagPrefix(tagPrefix: tagPrefix), data: $0.data) }
  }
}

extension TagFilter {
  fileprivate func filter(tags: [String], prefix: String) -> [String] {
    switch self {
    case .ordered:
      tags.orderedMatching(tagPrefix: prefix)
    case .stamped:
      tags.stampOrderedMatching
    }
  }
}

struct GitTagData {
  struct Configuration {
    let directory: URL
    let tagPrefix: String
    let branch: String?
    let fileName: String
    let tagFilter: TagFilter

    init(
      directory: URL, tagPrefix: String = "", branch: String? = nil, fileName: String,
      tagFilter: TagFilter
    ) {
      self.directory = directory
      self.tagPrefix = tagPrefix
      self.branch = branch
      self.fileName = fileName
      self.tagFilter = tagFilter
    }

    var file: URL {
      directory.appending(path: fileName)
    }

    func filter(tags: [String]) -> [String] {
      tagFilter.filter(tags: tags, prefix: tagPrefix)
    }
  }

  private let configuration: Configuration
  private let git: Git

  init(configuration: Configuration) throws {
    self.configuration = configuration
    self.git = Git(directory: configuration.directory, suppressStandardErr: true)
  }

  private struct ReadSequence: AsyncSequence {
    typealias Element = GitTaggedData

    let git: Git
    let tags: [String]
    let fileName: String

    struct AsyncIterator: AsyncIteratorProtocol {
      let git: Git
      let tags: [String]
      let fileName: String

      var index = 0

      mutating func next() async throws -> GitTaggedData? {
        guard !Task.isCancelled else { return nil }

        guard index < tags.count else { return nil }

        let tag = tags[index]

        Logger.gitTagData.info("tag: \(tag)")

        let data = try await git.show(commit: tag, path: fileName)

        index += 1

        return GitTaggedData(tag: tag, data: data)
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      AsyncIterator(git: git, tags: tags, fileName: fileName)
    }
  }

  func tagDatum() async throws -> [GitTaggedData] {
    try await self.git.status()

    var tagDatum: [GitTaggedData] = []
    for try await tagData in ReadSequence(
      git: git, tags: configuration.filter(tags: try await git.tags()),
      fileName: configuration.fileName)
    {
      tagDatum.append(tagData)
    }
    return tagDatum
  }

  func write(tagDatum: [GitTaggedData], initialCommit: String, version: String) async throws {
    enum WriteError: Error {
      case noBranch
    }

    guard let branch = configuration.branch else { throw WriteError.noBranch }

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
