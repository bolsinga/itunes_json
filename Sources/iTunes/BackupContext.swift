//
//  BackupContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct BackupContext: Sendable {
  static let defaultTag = "iTunes"

  let tagPrefix: String?
  let version: String

  func tag(_ tagProvider: @autoclosure () async throws -> String?) async throws -> String {
    if let tagPrefix { return tagPrefix }
    guard let currentPrefix = try await tagProvider()?.tagPrefix else {
      return Self.defaultTag
    }
    return currentPrefix
  }
}
