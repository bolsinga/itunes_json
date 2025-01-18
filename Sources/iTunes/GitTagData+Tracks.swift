//
//  GitTagData+Tracks.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let transform = Logger(category: "transform")
}

extension Tag where Item == Data {
  fileprivate func tracks() throws -> [Track] {
    try Track.array(from: self.item)
  }
}

extension GitTagData {
  func transformTracks<Transform: Sendable>(
    _ transform: @escaping @Sendable (String, [Track]) -> [Transform]
  ) async throws -> [Transform] {
    var tagDatum = try await self.tagDatum()

    return try await withThrowingTaskGroup(of: Array<Transform>.self) { group in
      for tagData in tagDatum.reversed() {
        tagDatum.removeLast()
        group.addTask {
          Logger.transform.info("transform: \(tagData.tag)")
          return transform(tagData.tag, try tagData.tracks())
        }
      }

      var allTransforms = [Transform]()
      for try await transforms in group {
        allTransforms.append(contentsOf: transforms)
      }
      return allTransforms
    }
  }

  func transformTaggedTracks<T: Sendable>(
    transform: @escaping @Sendable (String, [Track]) async throws -> T
  ) async throws -> [Tag<T>] {
    var tagDatum = try await self.tagDatum()

    return try await withThrowingTaskGroup(of: Tag<T>.self) { group in
      for tagData in tagDatum.reversed() {
        tagDatum.removeLast()
        group.addTask {
          Logger.transform.info("Transform Tag: \(tagData.tag)")
          return Tag(tag: tagData.tag, item: try await transform(tagData.tag, try tagData.tracks()))
        }
      }

      var tags: [Tag<T>] = []
      for try await tag in group {
        tags.append(tag)
      }
      return tags
    }
  }
}
