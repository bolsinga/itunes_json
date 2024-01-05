//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

class SQLSourceEncoder {
  enum SQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate final class Encoder {
    private var sqlRowEncoder = SQLRowEncoder()

    fileprivate func encode(_ track: Track) {
      sqlRowEncoder.encode(track)
    }

    private var kindStatements: (table: String, statements: [String]) {
      let rows = sqlRowEncoder.kindRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var artistStatements: (table: String, statements: [String]) {
      let rows = sqlRowEncoder.artistRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var albumStatements: (table: String, statements: [String]) {
      let rows = sqlRowEncoder.albumRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var songStatements: (table: String, statements: [String]) {
      let rows = sqlRowEncoder.songRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var playStatements: (table: String, statements: [String]) {
      let rows = sqlRowEncoder.playRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var tableStatements: [(table: String, statements: [String])] {
      [kindStatements, artistStatements, albumStatements, songStatements, playStatements]
    }

    fileprivate var sqlStatements: String {
      (["PRAGMA foreign_keys = ON;"]
        + tableStatements.flatMap {
          var statements = [$0.table, "BEGIN;"]
          statements.append(contentsOf: $0.statements.sorted())
          statements.append("COMMIT;")
          return statements
        }.compactMap { $0 }).joined(separator: "\n")
    }
  }

  func encode(_ tracks: [Track]) throws -> String {
    let encoder = Encoder()
    tracks.filter { $0.isSQLEncodable }.forEach { encoder.encode($0) }
    return encoder.sqlStatements
  }

  func encode(_ tracks: [Track]) throws -> Data {
    guard let data = try encode(tracks).data(using: .utf8) else {
      throw SQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
