//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

struct TracksSQLSourceEncoder {
  fileprivate struct Encoder {
    private let rowEncoder: TrackRowEncoder

    init(rowEncoder: TrackRowEncoder) {
      self.rowEncoder = rowEncoder
    }

    private func tableBuilders(laxSchemaOptions: LaxSchemaOptions) -> [(
      any TableBuilder, SchemaConstraints
    )] {
      [
        (rowEncoder.artistTableBuilder, laxSchemaOptions.artistConstraints),
        (rowEncoder.albumTableBuilder, laxSchemaOptions.albumConstraints),
        (rowEncoder.songTableBuilder(), laxSchemaOptions.songConstraints),
        (rowEncoder.playTableBuilder(), laxSchemaOptions.playsConstraints),
      ]
    }

    fileprivate func sqlStatements(laxSchemaOptions: LaxSchemaOptions) -> String {
      (["PRAGMA foreign_keys = ON;"]
        + tableBuilders(laxSchemaOptions: laxSchemaOptions).flatMap {
          var statements = [$0.schema(constraints: $1)]
          statements.append(contentsOf: $0.statements.map { "\($0)" }.sorted())
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(
    _ tracks: [Track], loggingToken: String?, laxSchemaOptions: LaxSchemaOptions
  ) -> String {
    let encoder = Encoder(rowEncoder: tracks.rowEncoder(loggingToken))
    return encoder.sqlStatements(laxSchemaOptions: laxSchemaOptions)
  }

  func encode(_ tracks: [Track], loggingToken: String?, laxSchemaOptions: LaxSchemaOptions) throws
    -> Data
  {
    enum TracksSQLSourceEncoderError: Error {
      case cannotMakeData
    }
    guard
      let data = encode(tracks, loggingToken: loggingToken, laxSchemaOptions: laxSchemaOptions)
        .data(using: .utf8)
    else {
      throw TracksSQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
