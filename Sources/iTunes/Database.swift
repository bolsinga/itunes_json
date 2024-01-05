//
//  Database.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation
import SQLite3

enum DatabaseError: Error {
  case cannotOpen(String)
}

extension OpaquePointer {
  fileprivate var sqlError: String {
    "\(String(cString: sqlite3_errmsg(self), encoding: .utf8) ?? "unknown") \(sqlite3_errcode(self))"
  }
}

actor Database {
  private let handle: OpaquePointer

  init(file: URL) throws {
    var handle: OpaquePointer?
    let result = sqlite3_open_v2(
      file.absoluteString, &handle, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil)

    guard let handle else { throw DatabaseError.cannotOpen("No handle") }
    guard result == SQLITE_OK else { throw DatabaseError.cannotOpen(handle.sqlError) }

    self.handle = handle
  }

  deinit { sqlite3_close(handle) }
}
