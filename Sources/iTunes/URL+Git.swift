//
//  URL+Git.swift
//
//
//  Created by Greg Bolsinga on 3/21/24.
//

import Foundation
import Git

extension URL {
  fileprivate var parentDirectory: URL {
    self.deletingLastPathComponent()
  }

  var parentDirectoryGit: Git {
    Git(directory: self.parentDirectory)
  }
}
