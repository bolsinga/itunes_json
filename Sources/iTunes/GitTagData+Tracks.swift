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

extension GitTaggedData {
  fileprivate func tracks() throws -> [Track] {
    try Track.array(from: self.data)
  }
}

extension GitTagData {
  func transformTracks<Transform: Hashable & Sendable>(
    _ transform: @escaping @Sendable (String, [Track]) -> Set<Transform>
  ) async throws -> Set<Transform> {
    var tagDatum = try await self.tagDatum()

    return try await withThrowingTaskGroup(of: Set<Transform>.self) { group in
      for tagData in tagDatum.reversed() {
        tagDatum.removeLast()
        group.addTask {
          Logger.transform.info("transform: \(tagData.tag)")
          return transform(tagData.tag, try tagData.tracks())
        }
      }

      var allNames: Set<Transform> = []
      for try await tracksNames in group {
        allNames = allNames.union(tracksNames)
      }
      return allNames
    }
  }

  func transformTaggedTracks(transform: @escaping @Sendable (String, [Track]) async throws -> Data)
    async throws -> [GitTaggedData]
  {
    var tagDatum = try await self.tagDatum()

    return try await withThrowingTaskGroup(of: GitTaggedData.self) { group in
      for tagData in tagDatum.reversed() {
        tagDatum.removeLast()
        group.addTask {
          Logger.transform.info("Transform Tag: \(tagData.tag)")
          return GitTaggedData(
            tag: tagData.tag, data: try await transform(tagData.tag, try tagData.tracks()))
        }
      }

      var tagDatum: [GitTaggedData] = []
      for try await tagData in group {
        tagDatum.append(tagData)
      }
      return tagDatum
    }
  }
}
