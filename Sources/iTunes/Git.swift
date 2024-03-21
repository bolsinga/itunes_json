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
  fileprivate static func git(arguments: [String]) throws -> Int32 {
    let git = try Self.run(URL(filePath: "/usr/bin/git"), arguments: arguments)
    git.waitUntilExit()
    return git.terminationStatus
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

  fileprivate func git(_ arguments: [String]) throws -> Int32 {
    try Process.git(arguments: gitPathArguments + arguments)
  }

  func status() throws {
    let terminationStatus = try git(["status"])
    guard terminationStatus == 0 else { throw GitError.status(terminationStatus) }
  }

  func checkoutMain() throws {
    let terminationStatus = try git(["checkout", "main"])
    guard terminationStatus == 0 else { throw GitError.main(terminationStatus) }
  }

  func add(_ filename: String) throws {
    let terminationStatus = try git(["add", filename])
    guard terminationStatus == 0 else { throw GitError.add(terminationStatus) }
  }

  func commit(_ message: String) throws {
    let terminationStatus = try git(["commit", "-m", message])
    guard terminationStatus == 0 else { throw GitError.commit(terminationStatus) }
  }

  func tag(_ name: String) throws {
    let terminationStatus = try git(["tag", name])
    guard terminationStatus == 0 else { throw GitError.tag(terminationStatus) }
  }

  func push() throws {
    let terminationStatus = try git(["push"])
    guard terminationStatus == 0 else { throw GitError.push(terminationStatus) }
  }

  func pushTags() throws {
    let terminationStatus = try git(["push", "--tags"])
    guard terminationStatus == 0 else { throw GitError.pushTags(terminationStatus) }
  }

  func gc() throws {
    let terminationStatus = try git(["gc", "--prune=now"])
    guard terminationStatus == 0 else { throw GitError.gc(terminationStatus) }
  }
}
