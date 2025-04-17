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
  case memoryError
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

  typealias Column = (column: String, value: Value)
  typealias Row = [Column]

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

      var integer: Int64? {
        switch self {
        case .integer(let int64):
          int64
        case .string(_), .null:
          nil
        }
      }

      var string: String? {
        switch self {
        case .integer(_), .null:
          nil
        case .string(let string):
          string
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
    private let cString: ContiguousArray<CChar>
    private let offset: Int
    private let logging: Logging

    fileprivate init(
      handle: StatementHandle, cString: ContiguousArray<CChar>, offset: Int, logging: Logging
    ) {
      self.handle = handle
      self.cString = cString
      self.offset = offset
      self.logging = logging
    }

    init(sql: Statement, db: isolated Database) throws {
      try self.init(string: sql.sql, db: db)
    }

    init(string: String, db: isolated Database) throws {
      try self.init(cString: string.utf8CString, offset: 0, db: db)
    }

    fileprivate init(cString: ContiguousArray<CChar>, offset: Int, db: isolated Database) throws {
      let (handle, newOffset) = try cString.withUnsafeBufferPointer { buffer in
        guard let baseAddress = buffer.baseAddress else {
          throw DatabaseError.memoryError
        }

        var statementHandle: StatementHandle?
        var remainderPtr: UnsafePointer<CChar>?

        let offsetCopy = offset

        let result = sqlite3_prepare_v3(
          db.handle, baseAddress + offset, -1, UInt32(SQLITE_PREPARE_PERSISTENT),
          &statementHandle, &remainderPtr)

        guard result == SQLITE_OK, let statementHandle else {
          db.logging.prepare.error(
            "\(String(cString: baseAddress + offsetCopy), privacy: .public) (result: \(result, privacy: .public))"
          )
          throw DatabaseError.cannotPrepare(db.handle.sqlError)
        }

        let newOffset = remainderPtr! - baseAddress
        return (statementHandle, newOffset)
      }
      self.init(handle: handle, cString: cString, offset: newOffset, logging: db.logging)
    }

    func next(db: isolated Database) throws -> PreparedStatement? {
      guard offset < cString.count - 1 else { return nil }
      return try PreparedStatement(cString: cString, offset: offset, db: db)
    }

    private var expandedSQL: String {
      String(cString: sqlite3_expanded_sql(handle), encoding: .utf8) ?? "unknown"
    }

    var parameterCount: Int {
      Int(sqlite3_bind_parameter_count(handle))
    }

    func close() {
      let result = sqlite3_finalize(handle)
      if result != SQLITE_OK {
        logging.finalize.error("\(result, privacy: .public)")
      }
    }

    func bind(arguments: [Value], errorStringBuilder: () -> String) throws {
      do {
        for index in 1...arguments.count {
          let value = arguments[index - 1]
          try value.bind(
            statementHandle: handle, index: index, errorStringBuilder: errorStringBuilder)
        }
      } catch {
        logging.bind.error(
          "sql: \(expandedSQL, privacy: .public) error: \(error.localizedDescription, privacy: .public)"
        )
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
        let column = Column(column: columnNames[Int(index)], value: try columnValue(for: index))
        row.append(column)
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
        logging.step.error(
          "sql: \(expandedSQL, privacy: .public) error: \(message, privacy: .public)")
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

  struct Context {
    let storage: DatabaseStorage
    let loggingToken: String?
  }

  private let handle: DatabaseHandle
  private let logging: Logging

  init(context: Context) throws {
    self.logging = Logging(token: context.loggingToken)

    var handle: DatabaseHandle?
    let result = sqlite3_open_v2(
      context.storage.name, &handle, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil)

    guard result == SQLITE_OK else {
      var errorString: String?
      if let handle {
        errorString = handle.sqlError
      } else {
        errorString = String(cString: sqlite3_errstr(result))
      }
      logging.open.error("\(result, privacy: .public)")
      guard let errorString else { throw DatabaseError.cannotOpen("Unknown") }
      throw DatabaseError.cannotOpen(errorString)
    }
    guard let handle else {
      logging.open.error("No handle")
      throw DatabaseError.cannotOpen("No handle")
    }

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
    if result != SQLITE_OK {
      logging.close.error("\(result, privacy: .public)")
    }
  }

  func execute(_ string: String) throws {
    let result = sqlite3_exec(handle, string, nil, nil, nil)
    guard result == SQLITE_OK else {
      logging.exec.error("\(string, privacy: .public) (result: \(result, privacy: .public))")
      throw DatabaseError.cannotExecute(handle.sqlError)
    }
  }

  func execute(query: String, arguments: [Database.Value]) throws -> [[Row]] {
    try transaction { db in
      var queryResult = [[Row]]()

      var statement: PreparedStatement? = try Database.PreparedStatement(string: query, db: db)
      while statement != nil {
        let result = try statement!.executeAndClose(db) { statement, db in
          let parameterCount = statement.parameterCount
          if parameterCount > 0 && parameterCount == arguments.count {
            try statement.bind(arguments: arguments) { db.errorString }
          }
          return try statement.execute { db.errorString }
        }
        queryResult.append(result)
        statement = try statement?.next(db: db)
      }

      return queryResult
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

  var filename: String {
    String(cString: sqlite3_db_filename(handle, nil), encoding: .utf8) ?? ""
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
