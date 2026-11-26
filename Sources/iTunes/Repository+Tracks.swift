//
//  Repository+Tracks.swift
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

/// Thrown after every tag has been processed, if the transform failed for one or more of them.
struct TransformError: Error, CustomStringConvertible {
  struct Failure: Sendable {
    let tag: String
    let error: any Error
  }

  /// The tags that failed, in tag order.
  let failures: [Failure]

  /// How many failures `description` spells out.
  private static let describedCount = 10

  var description: String {
    let shown = failures.prefix(Self.describedCount).map { "\($0.tag): \($0.error)" }
    let remaining = failures.count - shown.count
    let more = remaining > 0 ? ["... and \(remaining) more"] : []
    return (["The transform failed for \(failures.count) tag(s)."] + shown + more).joined(
      separator: "\n")
  }
}

extension Repository {
  /// Runs `transform` on the tracks of every tag, yielding each result as it is ready.
  ///
  /// A failure in one tag does not stop the others. Once all of them have run, the stream throws a
  /// `TransformError` that names every tag that failed. Errors from reading the repository stop
  /// the stream right away.
  func transformTracks<T: Sendable>(
    transform: @escaping @Sendable (String, [Track]) async throws -> T
  ) -> AsyncThrowingStream<Tag<T>, any Error> {
    let (stream, continuation) = AsyncThrowingStream<Tag<T>, Error>.makeStream()
    Task.detached {
      defer { continuation.finish() }

      do {
        let failures = try await withThrowingTaskGroup(of: TransformError.Failure?.self) { group in
          for try await tagData in tagDatum() {
            group.addTask {
              Logger.transform.info("Transform Tag: \(tagData.tag)")
              do {
                continuation.yield(
                  Tag(
                    tag: tagData.tag, item: try await transform(tagData.tag, try tagData.tracks())))
                return nil
              } catch {
                Logger.transform.error("Transform Tag failed: \(tagData.tag)")
                return TransformError.Failure(tag: tagData.tag, error: error)
              }
            }
          }

          // Child errors are only reported if the group is awaited. Without this they are dropped.
          return try await group.reduce(into: [TransformError.Failure]()) {
            if let failure = $1 { $0.append(failure) }
          }
        }

        if !failures.isEmpty {
          continuation.finish(
            throwing: TransformError(failures: failures.sorted(by: { $0.tag < $1.tag })))
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }

    return stream
  }
}
