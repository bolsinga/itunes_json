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
      sqlite3_finalize(handle)
    }

    private func bind(db: Database, value: Value, index: Int32) throws {
      switch value {
      case .string(let string):
        let result = sqlite3_bind_text(handle, index, string, -1, Statement.SQLITE_TRANSIENT)
        guard result == SQLITE_OK else {
          throw DatabaseError.cannotBind("\(db.handle.sqlError) - \(value.description) - \(index)")
        }
      case .integer(let integer):
        let result = sqlite3_bind_int64(handle, index, integer)
        guard result == SQLITE_OK else {
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
        sqlite3_reset(handle)
        sqlite3_clear_bindings(handle)
      }

      guard result == SQLITE_ROW || result == SQLITE_DONE else {
        throw DatabaseError.cannotStep(handle.sqlError)
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

    guard let handle else { throw DatabaseError.cannotOpen("No handle") }
    guard result == SQLITE_OK else { throw DatabaseError.cannotOpen(handle.sqlError) }

    self.handle = handle
  }

  deinit {
    statements.values.forEach { $0.close() }
    sqlite3_close(handle)
  }

  func execute(_ string: String) throws {
    let result = sqlite3_exec(handle, string, nil, nil, nil)
    guard result == SQLITE_OK else { throw DatabaseError.cannotExecute(handle.sqlError) }
  }

  func prepare(_ string: String) throws -> Statement {
    if let statement = statements[string] { return statement }

    var statementHandle: OpaquePointer?
    let result = sqlite3_prepare_v3(
      handle, string, -1, UInt32(SQLITE_PREPARE_PERSISTENT), &statementHandle, nil)

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
