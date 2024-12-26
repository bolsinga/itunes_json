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

    private func tableBuilders(schemaOptions: LaxSchemaOptions) -> [(
      any TableBuilder, SchemaConstraints
    )] {
      [
        (rowEncoder.artistTableBuilder, schemaOptions.artistConstraints),
        (rowEncoder.albumTableBuilder, schemaOptions.albumConstraints),
        (rowEncoder.songTableBuilder(), schemaOptions.songConstraints),
        (rowEncoder.playTableBuilder(), schemaOptions.playsConstraints),
      ]
    }

    fileprivate func sqlStatements(schemaOptions: LaxSchemaOptions) -> String {
      (["PRAGMA foreign_keys = ON;"]
        + tableBuilders(schemaOptions: schemaOptions).flatMap {
          var statements = [$0.schema(constraints: $1)]
          statements.append(contentsOf: $0.statements.map { "\($0)" }.sorted())
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(
    _ tracks: [Track], loggingToken: String?, schemaOptions: LaxSchemaOptions
  ) -> String {
    let encoder = Encoder(rowEncoder: tracks.rowEncoder(loggingToken))
    return encoder.sqlStatements(schemaOptions: schemaOptions)
  }

  func encode(_ tracks: [Track], loggingToken: String?, schemaOptions: LaxSchemaOptions) throws
    -> Data
  {
    enum TracksSQLSourceEncoderError: Error {
      case cannotMakeData
    }
    guard
      let data = encode(tracks, loggingToken: loggingToken, schemaOptions: schemaOptions)
        .data(using: .utf8)
    else {
      throw TracksSQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
