//
//  URL+Git.swift
//
//
//  Created by Greg Bolsinga on 3/21/24.
//

import Foundation

extension URL {
  fileprivate var parentDirectory: URL {
    self.deletingLastPathComponent()
  }

  fileprivate var filename: String {
    self.lastPathComponent
  }

  func gitAddCommitTagPush(message: String) throws {
    let git = Git(directory: self.parentDirectory)

    try git.status()
    try git.checkoutMain()
    try git.add(self.filename)
    var tagName = message
    do {
      try git.commit(message)
    } catch {
      tagName = tagName + "-empty"
    }
    try git.tag(tagName)
    try git.push()
    try git.pushTags()
    try git.gc()
  }
}
