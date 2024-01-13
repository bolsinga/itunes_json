//
//  Database.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation
import SQLite3
import os

extension Logger {
  static let open = Logger(subsystem: "sql", category: "open")
  static let close = Logger(subsystem: "sql", category: "close")
  static let exec = Logger(subsystem: "sql", category: "exec")
  static let prepare = Logger(subsystem: "sql", category: "prepare")
  static let step = Logger(subsystem: "sql", category: "step")
  static let reset = Logger(subsystem: "sql", category: "reset")
  static let clear = Logger(subsystem: "sql", category: "clear")
  static let finalize = Logger(subsystem: "sql", category: "finalize")
  static let bindText = Logger(subsystem: "sql", category: "bindText")
  static let bindInt64 = Logger(subsystem: "sql", category: "bindInt64")
}

enum DatabaseError: Error {
  case cannotOpen(String)
  case cannotEnableWALJournaling(String)
  case cannotEnableSynchrounsNormal(String)
  case cannotExecute(String)
  case cannotPrepare(String)
  case cannotBind(String)
  case cannotStep(String)
  case unexpectedColumns(Int32)
}

extension OpaquePointer {
  fileprivate var sqlError: String {
    "\(String(cString: sqlite3_errmsg(self), encoding: .utf8) ?? "unknown") \(sqlite3_errcode(self))"
  }
}

actor Database {
  enum Value: CustomStringConvertible {
    case string(String)
    case integer(Int64)

    var description: String {
      switch self {
      case .string(let string):
        "Value: \"\(string)\""
      case .integer(let integer):
        "Value: \(integer)"
      }
    }
  }

  struct Statement {
    private let handle: OpaquePointer

    static private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init(handle: OpaquePointer) {
      self.handle = handle
    }

    func close() {
      let result = sqlite3_finalize(handle)
      Logger.finalize.log("\(result, privacy: .public)")
    }

    private func bind(db: Database, value: Value, index: Int32) throws {
      switch value {
      case .string(let string):
        let result = sqlite3_bind_text(handle, index, string, -1, Statement.SQLITE_TRANSIENT)
        guard result == SQLITE_OK else {
          Logger.bindText.error("\(result, privacy: .public)")
          throw DatabaseError.cannotBind("\(db.handle.sqlError) - \(value.description) - \(index)")
        }
      case .integer(let integer):
        let result = sqlite3_bind_int64(handle, index, integer)
        guard result == SQLITE_OK else {
          Logger.bindInt64.error("\(result, privacy: .public)")
          throw DatabaseError.cannotBind("\(db.handle.sqlError) - \(value.description) - \(index)")
        }
      }
    }

    func bind(db: Database, count: Int32, binder: (Int32) -> Value) throws {
      for index in 1...count {
        try bind(db: db, value: binder(index), index: index)
      }
    }

    func execute(db: Database) throws {
      let result = sqlite3_step(handle)
      defer {
        var result = sqlite3_reset(handle)
        if result != SQLITE_OK { Logger.reset.error("\(result, privacy: .public)") }
        result = sqlite3_clear_bindings(handle)
        if result != SQLITE_OK { Logger.clear.error("\(result, privacy: .public)") }
      }

      guard result == SQLITE_ROW || result == SQLITE_DONE else {
        Logger.step.error("\(result, privacy: .public)")
        throw DatabaseError.cannotStep(db.handle.sqlError)
      }

      let columnCount = sqlite3_column_count(handle)
      guard columnCount == 0 else {
        throw DatabaseError.unexpectedColumns(columnCount)
      }
    }
  }

  private let handle: OpaquePointer
  private var statements = [String: Statement]()

  init(file: URL) throws {
    var handle: OpaquePointer?
    let result = sqlite3_open_v2(
      file.absoluteString, &handle, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil)

    Logger.open.log("\(result, privacy: .public)")
    guard let handle else { throw DatabaseError.cannotOpen("No handle") }
    guard result == SQLITE_OK else { throw DatabaseError.cannotOpen(handle.sqlError) }

    self.handle = handle

    guard sqlite3_exec(handle, "PRAGMA journal_mode = WAL", nil, nil, nil) == SQLITE_OK else {
      throw DatabaseError.cannotEnableWALJournaling(handle.sqlError)
    }
    guard sqlite3_exec(handle, "PRAGMA synchronous = NORMAL", nil, nil, nil) == SQLITE_OK else {
      throw DatabaseError.cannotEnableSynchrounsNormal(handle.sqlError)
    }
  }

  deinit {
    statements.values.forEach { $0.close() }
    let result = sqlite3_close(handle)
    Logger.close.log("\(result, privacy: .public)")
  }

  func execute(_ string: String) throws {
    let result = sqlite3_exec(handle, string, nil, nil, nil)
    Logger.exec.log("\(string, privacy: .public) (result: \(result, privacy: .public))")
    guard result == SQLITE_OK else { throw DatabaseError.cannotExecute(handle.sqlError) }
  }

  func prepare(_ string: String) throws -> Statement {
    if let statement = statements[string] { return statement }

    var statementHandle: OpaquePointer?
    let result = sqlite3_prepare_v3(
      handle, string, -1, UInt32(SQLITE_PREPARE_PERSISTENT), &statementHandle, nil)

    Logger.prepare.log("\(string, privacy: .public) (result: \(result, privacy: .public))")
    guard let statementHandle else { throw DatabaseError.cannotPrepare(string) }
    guard result == SQLITE_OK else { throw DatabaseError.cannotPrepare(handle.sqlError) }

    let statement = Statement(handle: statementHandle)
    statements[string] = statement
    return statement
  }

  var lastID: Int64 {
    sqlite3_last_insert_rowid(handle)
  }
}
