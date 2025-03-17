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


extension Git {
  fileprivate func addAndTag(fileName: String, tag tagName: String, version: String) async throws {
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
  fileprivate func add(to git: Git, backupFile: URL, version: String) async throws {
    Logger.gitTagData.info("Add: \(tag)")

    // this makes memory shoot up, unexpectedly.
    try item.write(to: backupFile)

    try await git.addAndTag(fileName: backupFile.lastPathComponent, tag: tag, version: version)
  }
}

struct GitTagData {
  let backupFile: URL
  private let git: Git

  init(backupFile: URL) throws {
    self.backupFile = backupFile
    self.git = Git(directory: backupFile.parentDirectory, suppressStandardErr: true)
  }

  private struct ReadSequence: AsyncSequence {
    typealias Element = Tag<Data>

    let tags: [String]
    let dataProvider: (String) async throws -> Data

    struct AsyncIterator: AsyncIteratorProtocol {
      let tags: [String]
      let limit: Int
      let dataProvider: (String) async throws -> Data

      internal init(
        tags: [String], limit: Int = Int.max, dataProvider: @escaping (String) async throws -> Data
      ) {
        self.tags = tags
        self.limit = limit
        self.dataProvider = dataProvider
      }

      var index = 0

      mutating func next() async throws -> Element? {
        guard !Task.isCancelled else { return nil }

        guard index < tags.count else { return nil }

        guard index < limit else { return nil }

        let tag = tags[index]

        Logger.gitTagData.info("tag: \(tag)")

        let data = try await dataProvider(tag)

        index += 1

        return Element(tag: tag, item: data)
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      AsyncIterator(tags: tags, dataProvider: dataProvider)
    }
  }

  func tagDatum() async throws -> [Tag<Data>] {
    try await self.git.status()

    var tagDatum: [Tag<Data>] = []
    for try await tagData in ReadSequence(
      tags: try await git.tags().stampOrderedMatching,
      dataProvider: {
        try await git.show(commit: $0, path: backupFile.filename)
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

      try await tagData.add(to: git, backupFile: backupFile, version: version)
    }

    //    try await git.push()
    //    try await git.pushTags()
    //    try await git.gc()
  }
}
