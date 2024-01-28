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

    private var artistStatements: (table: String, statements: [String]) {
      let rows = rowEncoder.artistRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var albumStatements: (table: String, statements: [String]) {
      let rows = rowEncoder.albumRows
      return (rows.table, rows.rows.map { $0.insert })
    }

    private var songStatements: (table: String, statements: [String]) {
      let rows = rowEncoder.songRows
      return (
        rows.table,
        rows.rows.map { $0.song.insert(artistID: $0.artist.selectID, albumID: $0.album.selectID) }
      )
    }

    private var playStatements: (table: String, statements: [String]) {
      let rows = rowEncoder.playRows
      return (
        rows.table,
        rows.rows.map {
          $0.play!.insert(
            songid: $0.song.selectID(artistID: $0.artist.selectID, albumID: $0.album.selectID))
        }
      )
    }

    private var tableStatements: [(table: String, statements: [String])] {
      [artistStatements, albumStatements, songStatements, playStatements]
    }

    fileprivate var sqlStatements: String {
      (["PRAGMA foreign_keys = ON;"]
        + tableStatements.flatMap {
          var statements = [$0.table, "BEGIN;"]
          statements.append(contentsOf: $0.statements.sorted())
          statements.append("COMMIT;")
          return statements
        } + [rowEncoder.views].compactMap { $0 }).joined(separator: "\n")
    }
  }

  private func encode(_ tracks: [Track]) throws -> String {
    let encoder = Encoder(rowEncoder: tracks.rowEncoder)
    return encoder.sqlStatements
  }

  func encode(_ tracks: [Track]) throws -> Data {
    guard let data = try encode(tracks).data(using: .utf8) else {
      throw SQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
