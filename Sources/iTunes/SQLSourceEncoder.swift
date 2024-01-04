//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation
import os

extension Logger {
  static let duplicateArtist = Logger(subsystem: "sql", category: "duplicateArtist")
}

extension Track {
  fileprivate var rows: (song: RowSong, play: RowPlay<RowSong>?) {
    let song = rowSong(artist: rowArtist, album: rowAlbum, kind: rowKind)
    return (song: song, play: rowPlay(using: song))
  }
}

class SQLSourceEncoder {
  enum SQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate final class Encoder {
    private var songRows = Set<RowSong>()
    private var playRows = Set<RowPlay<RowSong>>()

    fileprivate func encode(_ track: Track) {
      let rows = track.rows
      songRows.insert(rows.song)
      if let play = rows.play {
        playRows.insert(play)
      }
    }

    private var kindStatements: (table: String, statements: [String]) {
      (Track.KindTable, Array(Set(Array(songRows).map { $0.kind })).map { $0.insert })
    }

    private var artistStatements: (table: String, statements: [String]) {
      let artistRows = Array(Set(Array(songRows).map { $0.artist }))

      artistRows.mismatchedSortableNames.forEach {
        Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
      }

      return (Track.ArtistTable, artistRows.map { $0.insert })
    }

    private var albumStatements: (table: String, statements: [String]) {
      (Track.AlbumTable, Array(Set(Array(songRows).map { $0.album })).map { $0.insert })
    }

    private var songStatements: (table: String, statements: [String]) {
      (Track.SongTable, Array(songRows).map { $0.insert })
    }

    private var playStatements: (table: String, statements: [String]) {
      (Track.PlaysTable, Array(playRows).map { $0.insert })
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
