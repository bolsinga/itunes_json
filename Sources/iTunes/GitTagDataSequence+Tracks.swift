//
//  GitTagData+Tracks.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation

extension GitTagDataSequence {
  public func transformTracks<Transform: Hashable & Sendable>(
    _ transform: @escaping @Sendable ([Track]) -> Set<Transform>
  ) async throws -> Set<Transform> {
    var tagData = try await self.data()

    return try await withThrowingTaskGroup(of: Set<Transform>.self) { group in
      for data in tagData.reversed() {
        tagData.removeLast()
        group.addTask {
          transform(try Track.createFromData(data))
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
