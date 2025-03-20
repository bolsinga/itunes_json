//
//  BackupContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct BackupContext: Sendable {
  static let defaultTag = "iTunes"

  let version: String

  func tag(_ tagProvider: @autoclosure () async throws -> String?) async throws -> String {
    let tagParser = TagParser()
    guard let tag = try await tagProvider(), let currentPrefix = tagParser.tagPrefix(tag) else {
      return Self.defaultTag
    }
    return currentPrefix
  }
}
