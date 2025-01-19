//
//  Database.swift
//
//
//  Created by Greg Bolsinga on 1/5/24.
//

import Foundation
import SQLite3
import os

enum DatabaseError: Error {
  case cannotOpen(String)
  case cannotEnableWALJournaling(String)
  case cannotEnableSynchrounsNormal(String)
  case cannotExecute(String)
  case cannotPrepare(String)
  case cannotBind(String)
  case cannotStep(String)
  case cannotSerialize
  case noColumnName(Int)
  case unimplementedColumnType(Int)
  case noColumnText(Int)
}

extension DatabaseHandle {
  fileprivate var sqlError: String {
    "\(String(cString: sqlite3_errmsg(self), encoding: .utf8) ?? "unknown") \(sqlite3_errcode(self))"
  }
}

typealias DatabaseHandle = OpaquePointer
typealias StatementHandle = OpaquePointer

actor Database {
  typealias Value = Statement.Value

  typealias Row = [String: Value]

  fileprivate struct Logging {
    let open: Logger
    let close: Logger
    let exec: Logger
    let prepare: Logger
    let step: Logger
    let reset: Logger
    let clear: Logger
    let finalize: Logger
    let bind: Logger

    init(token: String?) {
      self.open = Logger(type: "sql", category: "open", token: token)
      self.close = Logger(type: "sql", category: "close", token: token)
      self.exec = Logger(type: "sql", category: "exec", token: token)
      self.prepare = Logger(type: "sql", category: "prepare", token: token)
      self.step = Logger(type: "sql", category: "step", token: token)
      self.reset = Logger(type: "sql", category: "reset", token: token)
      self.clear = Logger(type: "sql", category: "clear", token: token)
      self.finalize = Logger(type: "sql", category: "finalize", token: token)
      self.bind = Logger(type: "sql", category: "bind", token: token)
    }
  }

  struct Statement {
    static let empty: Statement = "\(Int(0))"

    var sql: String
    var parameters: [Value]

    init(sql: String = "", parameters: [Value] = []) {
      self.sql = sql
      self.parameters = parameters
    }

    enum Value: CustomStringConvertible {
      case integer(Int64)
      case string(String)
      case null

      func bind(statementHandle: StatementHandle, index: Int, errorStringBuilder: () -> String)
        throws
      {
        let result =
          switch self {
          case .string(let string):
            sqlite3_bind_text(statementHandle, Int32(index), string, -1, Self.SQLITE_TRANSIENT)
          case .integer(let integer):
            sqlite3_bind_int64(statementHandle, Int32(index), integer)
          case .null:
            SQLITE_OK
          }

        guard result == SQLITE_OK else {
          throw DatabaseError.cannotBind("\(errorStringBuilder()) - \(self.description) - \(index)")
        }
      }

      var description: String {
        switch self {
        case .integer(let int64):
          return "\(int64)"
        case .string(let string):
          return string
        case .null:
          return "NULL"
        }
      }

      var sourceDescription: String {
        switch self {
        case .string(let string):
          "'\(string.replacingOccurrences(of: "'", with: "''"))'"
        default:
          self.description
        }
      }

      static private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    }

    func description(_ parameterDescriptor: (Value) -> String) -> String {
      let chunks = sql.split(separator: "?")
      let parameterizedChunks = zip(chunks, parameters.map { parameterDescriptor($0) }).flatMap {
        [String($0), String($1)]
      }
      let remainder = chunks.dropFirst(parameters.count).map { String($0) }
      return (parameterizedChunks + remainder).joined(separator: "")
    }
  }

  struct PreparedStatement {
    private let handle: StatementHandle
    private let logging: Logging

    static func create(sql: Statement, db: isolated Database) throws -> [PreparedStatement] {
      try create(string: sql.sql, db: db)
    }

    static func create(string: String, db: isolated Database) throws -> [PreparedStatement] {
      var statementHandle: StatementHandle?
      let result = sqlite3_prepare_v3(
        db.handle, string, -1, UInt32(SQLITE_PREPARE_PERSISTENT), &statementHandle, nil)

      db.logging.prepare.log("\(string, privacy: .public) (result: \(result, privacy: .public))")
      guard result == SQLITE_OK else { throw DatabaseError.cannotPrepare(db.handle.sqlError) }
      guard let statementHandle else { throw DatabaseError.cannotPrepare(string) }

      let statement = PreparedStatement(handle: statementHandle, logging: db.logging)
      return [statement]
    }

    private init(handle: StatementHandle, logging: Logging) {
      self.handle = handle
      self.logging = logging
    }

    func close() {
      let result = sqlite3_finalize(handle)
      logging.finalize.log("\(result, privacy: .public)")
    }

    func bind(arguments: [Value], errorStringBuilder: () -> String) throws {
      do {
        for index in 1...arguments.count {
          let value = arguments[index - 1]
          try value.bind(
            statementHandle: handle, index: index, errorStringBuilder: errorStringBuilder)
        }
      } catch {
        logging.bind.error("\(error.localizedDescription, privacy: .public)")
        throw error
      }
    }

    private func columnName(for index: Int32) throws -> String {
      guard let ptr = sqlite3_column_name(handle, index) else {
        throw DatabaseError.noColumnName(Int(index))
      }
      return String(cString: ptr)
    }

    private func columnValue(for index: Int32) throws -> Value {
      switch sqlite3_column_type(handle, index) {
      case SQLITE_NULL:
        return .null
      case SQLITE_INTEGER:
        return .integer(sqlite3_column_int64(handle, index))
      case SQLITE_TEXT:
        guard let ptr = sqlite3_column_text(handle, index) else {
          throw DatabaseError.noColumnText(Int(index))
        }
        return .string(String(cString: ptr))
      default:
        throw DatabaseError.unimplementedColumnType(Int(index))
      }
    }

    private func row(columnCount: Int32, columnNames: inout [String]) throws -> Row {
      var row = Row()

      for index in 0..<columnCount {
        if columnNames.count <= index {
          columnNames.append(try columnName(for: index))
        }
        row[columnNames[Int(index)]] = try columnValue(for: index)
      }

      return row
    }

    private func rows() throws -> [Row] {
      let columnCount = sqlite3_column_count(handle)
      guard columnCount != 0 else { return [] }

      var columnNames = [String]()
      var rows = [Row]()

      var result = SQLITE_ROW
      while result == SQLITE_ROW {
        rows.append(try row(columnCount: columnCount, columnNames: &columnNames))

        result = sqlite3_step(handle)
      }
      return rows
    }

    @discardableResult
    func execute(_ errorStringBuilder: () -> String) throws -> [Row] {
      let result = sqlite3_step(handle)
      defer {
        var result = sqlite3_reset(handle)
        if result != SQLITE_OK { logging.reset.error("\(result, privacy: .public)") }
        result = sqlite3_clear_bindings(handle)
        if result != SQLITE_OK { logging.clear.error("\(result, privacy: .public)") }
      }

      guard result == SQLITE_ROW || result == SQLITE_DONE else {
        let message = errorStringBuilder()
        logging.step.error("\(message, privacy: .public)")
        throw DatabaseError.cannotStep(message)
      }

      guard result == SQLITE_ROW else { return [] }

      return try rows()
    }

    @discardableResult
    func executeAndClose<R>(
      _ db: isolated Database, action: @Sendable (PreparedStatement, isolated Database) throws -> R
    ) throws -> R {
      let result = try action(self, db)
      close()
      return result
    }
  }

  private let handle: DatabaseHandle
  private let logging: Logging

  init(storage: DatabaseStorage, loggingToken: String?) throws {
    self.logging = Logging(token: loggingToken)

    var handle: DatabaseHandle?
    let result = sqlite3_open_v2(
      storage.name, &handle, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil)

    logging.open.log("\(result, privacy: .public)")
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

  func close() {
    let result = sqlite3_close(handle)
    logging.close.log("\(result, privacy: .public)")
  }

  func execute(_ string: String) throws {
    let result = sqlite3_exec(handle, string, nil, nil, nil)
    logging.exec.log("\(string, privacy: .public) (result: \(result, privacy: .public))")
    guard result == SQLITE_OK else { throw DatabaseError.cannotExecute(handle.sqlError) }
  }

  func execute(query: String) throws -> [[Row]] {
    try transaction { db in
      let statements = try Database.PreparedStatement.create(string: query, db: db)
      return try statements.map {
        try $0.executeAndClose(db) { statement, db in
          try statement.execute { db.errorString }
        }
      }
    }
  }

  @discardableResult
  func transaction<R>(_ action: @Sendable (isolated Database) throws -> R) throws -> R {
    try execute("BEGIN TRANSACTION")
    do {
      let result = try action(self)
      try execute("COMMIT TRANSACTION")
      return result
    } catch {
      try execute("ROLLBACK TRANSACTION")
      throw error
    }
  }

  var lastID: Int64 {
    sqlite3_last_insert_rowid(handle)
  }

  var errorString: String {
    handle.sqlError
  }

  func data() throws -> Data {
    var size: sqlite3_int64 = 0
    guard let bytes = sqlite3_serialize(handle, "main", &size, 0) else {
      throw DatabaseError.cannotSerialize
    }
    let data = Data(bytes: bytes, count: Int(size))
    sqlite3_free(bytes)
    return data
  }
}

extension Database.Statement: CustomStringConvertible {
  var description: String {
    self.description { $0.sourceDescription }
  }
}

protocol SQLiteStatementConvertible {
  var sqliteStatement: Database.Statement { get }
}

protocol SQLiteParameterConvertible: SQLiteStatementConvertible {
  var parameter: Database.Statement.Value { get }
}

extension SQLiteParameterConvertible {
  var sqliteStatement: Database.Statement {
    Database.Statement(sql: "?", parameters: [parameter])
  }
}

extension Int64: SQLiteParameterConvertible {
  var parameter: Database.Statement.Value { .integer(self) }
}

extension Int: SQLiteParameterConvertible {
  var parameter: Database.Statement.Value { .integer(Int64(self)) }
}

extension String: SQLiteParameterConvertible {
  var parameter: Database.Statement.Value { .string(self) }
}

extension Database.Statement: SQLiteStatementConvertible {
  var sqliteStatement: Database.Statement { self }
}

extension Database.Statement: ExpressibleByStringInterpolation {
  init(stringLiteral value: String) {
    self.init(sql: value)
  }

  init(stringInterpolation: StringInterpolation) {
    self = stringInterpolation.statement
  }

  struct StringInterpolation: StringInterpolationProtocol {
    var statement = Database.Statement()

    init(literalCapacity: Int, interpolationCount: Int) {
      statement.sql.reserveCapacity(literalCapacity + interpolationCount)
      statement.parameters.reserveCapacity(interpolationCount)
    }

    mutating func appendLiteral(_ literal: String) {
      statement.sql += literal
    }

    mutating func appendInterpolation<T: SQLiteStatementConvertible>(_ value: T?) {
      statement.sql += value?.sqliteStatement.sql ?? "?"
      statement.parameters += value?.sqliteStatement.parameters ?? [.null]
    }

    mutating func appendInterpolation(raw sql: Database.Statement) {
      appendInterpolation(sql)
    }
  }
}
