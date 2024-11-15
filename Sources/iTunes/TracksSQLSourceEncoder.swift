//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

struct TracksSQLSourceEncoder {
  enum TracksSQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate struct Encoder {
    private let rowEncoder: TrackRowEncoder

    init(rowEncoder: TrackRowEncoder) {
      self.rowEncoder = rowEncoder
    }

    private var tableBuilders: [any TableBuilder] {
      [
        rowEncoder.artistTableBuilder, rowEncoder.albumTableBuilder, rowEncoder.songTableBuilder(),
        rowEncoder.playTableBuilder(),
      ]
    }

    fileprivate func sqlStatements(schemaConstraints: SchemaConstraints) -> String {
      (["PRAGMA foreign_keys = ON;"]
        + tableBuilders.flatMap {
          var statements = [$0.schema(constraints: schemaConstraints)]
          statements.append(contentsOf: $0.statements.map { "\($0)" }.sorted())
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(
    _ tracks: [Track], loggingToken: String?, schemaConstraints: SchemaConstraints
  ) -> String {
    let encoder = Encoder(rowEncoder: tracks.rowEncoder(loggingToken))
    return encoder.sqlStatements(schemaConstraints: schemaConstraints)
  }

  func encode(_ tracks: [Track], loggingToken: String?, schemaConstraints: SchemaConstraints) throws
    -> Data
  {
    guard
      let data = encode(tracks, loggingToken: loggingToken, schemaConstraints: schemaConstraints)
        .data(using: .utf8)
    else {
      throw TracksSQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
