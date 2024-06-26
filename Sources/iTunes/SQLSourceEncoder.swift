//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

struct SQLSourceEncoder {
  enum SQLSourceEncoderError: Error {
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

    fileprivate var sqlStatements: String {
      (["PRAGMA foreign_keys = ON;"]
        + tableBuilders.flatMap {
          var statements = [$0.schema]
          statements.append(contentsOf: $0.statements.map { "\($0)" }.sorted())
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(_ tracks: [Track], loggingToken: String?) throws -> String {
    let encoder = Encoder(rowEncoder: tracks.rowEncoder(loggingToken))
    return encoder.sqlStatements
  }

  func encode(_ tracks: [Track], loggingToken: String?) throws -> Data {
    guard let data = try encode(tracks, loggingToken: loggingToken).data(using: .utf8) else {
      throw SQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
