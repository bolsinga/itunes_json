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

extension Process {
  @discardableResult
  fileprivate static func git(
    arguments: [String], errorBuilder: (Int32) -> Error, suppressStandardErr: Bool
  ) throws
    -> [String]
  {
    let git = Self.init()
    git.executableURL = URL(filePath: "/usr/bin/git")
    git.arguments = arguments
    let standardOutputPipe = Pipe()
    git.standardOutput = standardOutputPipe
    if suppressStandardErr { git.standardError = nil }
    try git.run()
    git.waitUntilExit()
    guard git.terminationStatus == 0 else { throw errorBuilder(git.terminationStatus) }

    let standardOutputData = try standardOutputPipe.fileHandleForReading.readToEnd()
    guard let standardOutputData else { return [] }

    guard let standardOutput = String(data: standardOutputData, encoding: .utf8) else { return [] }
    return standardOutput.components(separatedBy: "\n").filter { !$0.isEmpty }
  }
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
  fileprivate func git(_ arguments: [String], errorBuilder: (Int32) -> Error) throws -> [String] {
    try Process.git(
      arguments: gitPathArguments + arguments, errorBuilder: errorBuilder,
      suppressStandardErr: suppressStandardErr)
  }

  func status() throws {
    try git(["status"]) { GitError.status($0) }
  }

  func checkout(commit: String) throws {
    try git(["checkout", commit]) { GitError.main($0) }
  }

  func add(_ filename: String) throws {
    try git(["add", filename]) { GitError.add($0) }
  }

  func commit(_ message: String) throws {
    try git(["commit", "-m", message]) { GitError.commit($0) }
  }

  func tag(_ name: String) throws {
    try git(["tag", name]) { GitError.tag($0) }
  }

  func push() throws {
    try git(["push"]) { GitError.push($0) }
  }

  func pushTags() throws {
    try git(["push", "--tags"]) { GitError.pushTags($0) }
  }

  func gc() throws {
    try git(["gc", "--prune=now"]) { GitError.gc($0) }
  }

  func diff() throws {
    try git(["diff", "--staged", "--name-only", "--exit-code"]) { GitError.diff($0) }
  }

  func tagContains(_ message: String) throws -> [String] {
    try git(["tag", "--contains", message]) { GitError.contains($0) }
  }

  func tags() throws -> [String] {
    try git(["tag"]) { GitError.tags(($0)) }
  }
}
