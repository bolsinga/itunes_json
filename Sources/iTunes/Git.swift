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
}

extension Process {
  fileprivate static func git(arguments: [String], errorBuilder: (Int32) -> Error) throws {
    let git = try Self.run(URL(filePath: "/usr/bin/git"), arguments: arguments)
    git.waitUntilExit()
    guard git.terminationStatus == 0 else { throw errorBuilder(git.terminationStatus) }
  }
}

struct Git {
  private let path: String

  init(directory: URL) {
    self.path = directory.path(percentEncoded: false)
  }

  fileprivate var gitPathArguments: [String] {
    ["-C", path]
  }

  fileprivate func git(_ arguments: [String], errorBuilder: (Int32) -> Error) throws {
    try Process.git(arguments: gitPathArguments + arguments, errorBuilder: errorBuilder)
  }

  func status() throws {
    try git(["status"]) { GitError.status($0) }
  }

  func checkoutMain() throws {
    try git(["checkout", "main"]) { GitError.main($0) }
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
}
