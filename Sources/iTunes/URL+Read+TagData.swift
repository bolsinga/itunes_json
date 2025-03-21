//
//  URL+Read+TagData.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/30/24.
//

import Foundation
import GitLibrary
import os

extension Logger {
  fileprivate static let tagStream = Logger(category: "tagStream")
}

extension URL {
  var tagDatum: AsyncThrowingStream<Tag<Data>, Error> {
    let (stream, continuation) = AsyncThrowingStream<Tag<Data>, Error>.makeStream()
    Task.detached {
      defer { continuation.finish() }

      let git = Git(directory: self.parentDirectory, suppressStandardErr: true)

      do {
        try await git.status()

        for tag in try await git.tags().stampOrderedMatching {
          Logger.tagStream.info("tag: \(tag)")

          continuation.yield(
            Tag(tag: tag, item: try await git.show(commit: tag, path: self.filename)))
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }
    return stream
  }
}
