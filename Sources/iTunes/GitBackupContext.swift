//
//  GitBackupContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct GitBackupContext: Sendable {
  static let defaultTag = "iTunes"

  let repository: Repository
  let version: String

  private func tag(_ tagProvider: @autoclosure () async throws -> String?) async throws -> String {
    let tagParser = TagParser()
    guard let tag = try await tagProvider(), let currentPrefix = tagParser.tagPrefix(tag) else {
      return Self.defaultTag
    }
    return currentPrefix
  }

  func write(data: Data) async throws {
    try await repository.backup(version: version) {
      try await tag($0)
    } dataWriter: {
      try data.write(to: repository.backupFile, options: .atomic)
    }
  }
}
