//
//  URL+BackupFile.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/17/25.
//

import Foundation

extension URL {
  private static var backupFileName: String { "itunes.json" }

  var backupFile: URL {
    self.appending(path: Self.backupFileName)
  }
}
