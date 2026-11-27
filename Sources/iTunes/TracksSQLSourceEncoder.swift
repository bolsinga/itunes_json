//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

private enum TracksSQLSourceEncoderError: Error {
  case cannotMakeData
}

protocol TracksSQLSourceEncoderContext {
  var loggingToken: String? { get }
  var schemaOptions: SchemaOptions { get }
}

struct TracksSQLSourceEncoder<Context: TracksSQLSourceEncoderContext> {
  let context: Context

  fileprivate struct Encoder {
    private let rowEncoder: TrackRowEncoder

    init(rowEncoder: TrackRowEncoder) {
      self.rowEncoder = rowEncoder
    }

    private func tableBuilders(schemaOptions: SchemaOptions) throws -> [(
      any TableBuilder, SchemaConstraints
    )] {
      try [
        (rowEncoder.artistTableBuilder, schemaOptions.artistConstraints),
        (rowEncoder.albumTableBuilder(), schemaOptions.albumConstraints),
        (rowEncoder.songTableBuilder(), schemaOptions.songConstraints),
        (rowEncoder.addedTableBuilder, .strict),
        (rowEncoder.releasedTableBuilder, .strict),
        (rowEncoder.playTableBuilder, schemaOptions.playsConstraints),
      ]
    }

    fileprivate func sqlStatements(schemaOptions: SchemaOptions) throws -> String {
      try
        (["PRAGMA foreign_keys = ON;"]
        + tableBuilders(schemaOptions: schemaOptions).flatMap {
          var statements = [$0.schema(constraints: $1)]
          statements.append(contentsOf: $0.statements.map { "\($0)" }.sorted())
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(_ tracks: [Track]) throws -> String {
    let encoder = Encoder(rowEncoder: try tracks.rowEncoder(context.loggingToken))
    return try encoder.sqlStatements(schemaOptions: context.schemaOptions)
  }

  func encode(_ tracks: [Track]) throws -> Data {
    guard let data = try encode(tracks).data(using: .utf8) else {
      throw TracksSQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
