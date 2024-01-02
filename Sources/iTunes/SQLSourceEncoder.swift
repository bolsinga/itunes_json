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
  fileprivate var rows:
    (kind: RowKind, artist: RowArtist, album: RowAlbum, song: RowSong, play: RowPlay?)
  {
    let artist = rowArtist
    let album = rowAlbum
    let kind = rowKind
    let song = rowSong(artist: artist, album: album, kind: kind)
    return (
      kind: kind, artist: artist, album: album, song: song, play: rowPlay(using: song)
    )
  }
}

class SQLSourceEncoder {
  enum SQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate final class Encoder {
    private var kindRows = Set<RowKind>()
    private var artistRows = Set<RowArtist>()
    private var albumRows = Set<RowAlbum>()
    private var songRows = Set<RowSong>()
    private var playRows = Set<RowPlay>()

    fileprivate func encode(_ track: Track) {
      let rows = track.rows

      kindRows.insert(rows.kind)
      artistRows.insert(rows.artist)
      albumRows.insert(rows.album)
      songRows.insert(rows.song)
      if let play = rows.play {
        playRows.insert(play)
      }
    }

    private var kindStatements: (table: String, statements: [String]) {
      (Track.KindTable, Array(kindRows).map { $0.insert })
    }

    private var artistStatements: (table: String, statements: [String]) {
      let artistRows = Array(artistRows)

      artistRows.mismatchedSortableNames.forEach {
        Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
      }

      return (Track.ArtistTable, artistRows.map { $0.insert })
    }

    private var albumStatements: (table: String, statements: [String]) {
      (Track.AlbumTable, Array(albumRows).map { $0.insert })
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
