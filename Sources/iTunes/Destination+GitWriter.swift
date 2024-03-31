//
//  Destination+GitWriter.swift
//
//
//  Created by Greg Bolsinga on 3/31/24.
//

import Foundation

extension URL {
  fileprivate var filename: String {
    self.lastPathComponent
  }
}

extension Git {
  func addCommitTagPush(filename: String, message: String) throws {
    try status()
    try checkoutMain()
    try add(filename)
    var tagName = message
    do {
      try commit(message)
    } catch {
      tagName = tagName + "-empty"
    }
    try tag(tagName)
    try push()
    try pushTags()
    try gc()
  }
}

struct GitWriter: DestinationFileWriting {
  let fileWriter: FileWriter

  func write(data: Data) throws {
    try fileWriter.write(data: data)

    let git = fileWriter.outputFile.parentDirectoryGit
    try git.addCommitTagPush(
      filename: fileWriter.outputFile.filename, message: String.defaultDestinationName)
  }
}
