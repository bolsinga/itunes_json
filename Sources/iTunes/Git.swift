//
//  Git.swift
//
//
//  Created by Greg Bolsinga on 3/21/24.
//

import Foundation

enum GitError: Error {
  case status(Int32)
  case main(Int32)
  case add(Int32)
  case commit(Int32)
  case tag(Int32)
  case push(Int32)
  case pushTags(Int32)
  case gc(Int32)
  case diff(Int32)
  case contains(Int32)
  case tags(Int32)
}

struct Git {
  private let path: String
  private let suppressStandardErr: Bool

  init(directory: URL, suppressStandardErr: Bool = false) {
    self.path = directory.path(percentEncoded: false)
    self.suppressStandardErr = suppressStandardErr
  }

  fileprivate var gitPathArguments: [String] {
    ["-C", path]
  }

  @discardableResult
  fileprivate func git(_ arguments: [String], errorBuilder: (Int32) -> Error) async throws
    -> [String]
  {
    let gitArguments = gitPathArguments + arguments

    let result = try await launch(
      tool: URL(filePath: "/usr/bin/git"), arguments: gitArguments,
      suppressStandardErr: suppressStandardErr)
    guard result.0 == 0 else { throw errorBuilder(result.0) }

    guard let standardOutput = String(data: result.1, encoding: .utf8) else { return [] }
    return standardOutput.components(separatedBy: "\n").filter { !$0.isEmpty }
  }

  func status() async throws {
    try await git(["status"]) { GitError.status($0) }
  }

  func checkout(commit: String) async throws {
    try await git(["checkout", commit]) { GitError.main($0) }
  }

  func add(_ filename: String) async throws {
    try await git(["add", filename]) { GitError.add($0) }
  }

  func commit(_ message: String) async throws {
    try await git(["commit", "-m", message]) { GitError.commit($0) }
  }

  func tag(_ name: String) async throws {
    try await git(["tag", name]) { GitError.tag($0) }
  }

  func push() async throws {
    try await git(["push"]) { GitError.push($0) }
  }

  func pushTags() async throws {
    try await git(["push", "--tags"]) { GitError.pushTags($0) }
  }

  func gc() async throws {
    try await git(["gc", "--prune=now"]) { GitError.gc($0) }
  }

  func diff() async throws {
    try await git(["diff", "--staged", "--name-only", "--exit-code"]) { GitError.diff($0) }
  }

  func tagContains(_ message: String) async throws -> [String] {
    try await git(["tag", "--contains", message]) { GitError.contains($0) }
  }

  func tags() async throws -> [String] {
    try await git(["tag"]) { GitError.tags(($0)) }
  }
}
