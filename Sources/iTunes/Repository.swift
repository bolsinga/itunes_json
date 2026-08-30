//
//  Repository.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 8/23/26.
//

import Foundation
import GitLibrary

struct Repository {
  private let directory: URL
  let git: any Git

  internal init(directory: URL) {
    self.directory = directory
    self.git = Implementation.subProcess(directory: directory, suppressStandardErr: true)
      .create()
  }

  var backupFile: URL { directory.backupFile }
}
