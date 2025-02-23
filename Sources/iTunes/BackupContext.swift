//
//  BackupContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation
import GitLibrary

struct BackupContext: Sendable {
  static let defaultTag = "iTunes"

  let branch: String
  let tagPrefix: String?
  let version: String

  func tag(_ git: Git) async throws -> String {
    if let tagPrefix { return tagPrefix }
    guard let currentPrefix = try await git.describeTag()?.tagPrefix else {
      return Self.defaultTag
    }
    return currentPrefix
  }
}
