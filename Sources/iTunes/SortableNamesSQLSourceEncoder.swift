//
//  SortableNamesSQLSourceEncoder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/15/24.
//

import Foundation

extension SortableName: SQLBindableInsert {
  static var insertBinding: Database.Statement { SortableName().insert }

  var insert: Database.Statement {
    "INSERT INTO current (name, sortname) VALUES (\(name), \(sorted));"
  }
}

struct SortableNamesSQLSourceEncoder {
  enum SourceEncoderError: Error {
    case cannotMakeData
  }

  func encode(_ names: [SortableName], tableName: String) throws -> Data {
    guard
      let data = SortableNamesTableBuilder(rows: names, tableName: tableName).encode().data(
        using: .utf8)
    else { throw SourceEncoderError.cannotMakeData }
    return data
  }
}
