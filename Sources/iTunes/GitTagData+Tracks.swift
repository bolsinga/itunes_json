//
//  GitTagData+Tracks.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import os

extension Logger {
  fileprivate static let transform = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "transform")
}

extension TagData {
  fileprivate func tracks() throws -> [Track] {
    try Track.array(from: self.data)
  }
}

extension GitTagData {
  public func transformTracks<Transform: Hashable & Sendable>(
    _ transform: @escaping @Sendable ([Track]) -> Set<Transform>
  ) async throws -> Set<Transform> {
    var tagDatum = try await self.tagDatum()

    return try await withThrowingTaskGroup(of: Set<Transform>.self) { group in
      for tagData in tagDatum.reversed() {
        tagDatum.removeLast()
        group.addTask {
          Logger.transform.info("transform: \(tagData.tag)")
          return transform(try tagData.tracks())
        }
      }

      var allNames: Set<Transform> = []
      for try await tracksNames in group {
        allNames = allNames.union(tracksNames)
      }
      return allNames
    }
  }
}
