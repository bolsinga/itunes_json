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
  func validate() throws {
    try status()
    try checkoutMain()
  }

  func addCommitTagPush(filename: String, message: String) throws {
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
    let git = fileWriter.outputFile.parentDirectoryGit

    try git.validate()
    try fileWriter.write(data: data)

    try git.addCommitTagPush(
      filename: fileWriter.outputFile.filename, message: String.defaultDestinationName)
  }
}
