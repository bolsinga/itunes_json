//
//  TagSequence.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/17/25.
//

import Foundation
import os

extension Logger {
  fileprivate static let tagSequence = Logger(category: "tagSequence")
}

struct TagSequence: AsyncSequence {
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

      Logger.tagSequence.info("tag: \(tag)")

      let data = try await dataProvider(tag)

      index += 1

      return Element(tag: tag, item: data)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(tags: tags, dataProvider: dataProvider)
  }
}
