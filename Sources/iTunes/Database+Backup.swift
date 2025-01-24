//
//  Database+Backup.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/11/25.
//

import Foundation

extension Database {
  fileprivate func attachDB(at url: URL) throws {
    try self.transaction { db in
      try db.execute("ATTACH DATABASE \"\(url.absoluteString)\" AS backup;")
    }
  }

  func mergeIntoDB(at url: URL) async throws {
    try attachDB(at: url)
  }
}
