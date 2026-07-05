//
//  URL+Tracks.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import GitLibrary
import os

extension Logger {
  fileprivate static let transform = Logger(category: "transform")
}

extension Tag where Item == Data {
  fileprivate func tracks() throws -> [Track] {
    try Track.array(from: self.item)
  }
}

extension URL {
  func transformTracks<T: Sendable>(
    transform: @escaping @Sendable (String, [Track]) async throws -> T
  ) -> AsyncThrowingStream<Tag<T>, any Error> {
    let (stream, continuation) = AsyncThrowingStream<Tag<T>, Error>.makeStream()
    Task.detached {
      defer { continuation.finish() }

      let git = Implementation.outOfProcess(
        directory: self.parentDirectory, suppressStandardErr: true
      ).create()

      let filename = self.filename

      do {
        try await withThrowingTaskGroup(of: Void.self) { group in
          for try await tagData in git.tagDatum(filename: filename) {
            group.addTask {
              Logger.transform.info("Transform Tag: \(tagData.tag)")
              continuation.yield(
                Tag(tag: tagData.tag, item: try await transform(tagData.tag, try tagData.tracks())))
            }
          }
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    return stream
  }
}
