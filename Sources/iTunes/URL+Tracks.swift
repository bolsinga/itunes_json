//
//  URL+Tracks.swift
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

extension URL {
  func transformTracks<T: Sendable>(
    transform: @escaping @Sendable (String, [Track]) async throws -> T
  ) async throws -> [Tag<T>] {
    try await tagDatum.map { tagData in
      Logger.transform.info("Transform Tag: \(tagData.tag)")
      return Tag(tag: tagData.tag, item: try await transform(tagData.tag, try tagData.tracks()))
    }.reduce(into: [Tag<T>]()) {
      $0.append($1)
    }
  }
}
