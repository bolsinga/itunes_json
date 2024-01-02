//
//  DBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation
import SQLite3

enum DBError: Error {
  case cannotOpen(String)
}

final class DBEncoder {
  let handle: OpaquePointer

  init(file: URL) throws {
    var handle: OpaquePointer?
    let result = sqlite3_open_v2(
      file.absoluteString, &handle, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil)

    guard let handle else {
      throw DBError.cannotOpen("No handle")
    }
    self.handle = handle

    guard result == SQLITE_OK else {
      let code = sqlite3_errcode(handle)
      let message = String(cString: sqlite3_errmsg(handle), encoding: .utf8) ?? "unknown"

      throw DBError.cannotOpen("\(message) \(code)")
    }
  }

  deinit {
    sqlite3_close(handle)
  }

  func encode(_ tracks: [Track]) throws {

  }
}
