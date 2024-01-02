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

private protocol TrackEncoding {
  func encode(_ track: Track)
  var statements: String { get }
}

class SQLSourceEncoder {
  fileprivate final class KindTableData: TrackEncoding {
    private var values = Set<RowKind>()

    var statements: String {
      var keyStatements = Array(values).map { $0.insertStatement }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.KindTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      guard let row = track.rowKind else { return }

      values.insert(row)
    }
  }

  fileprivate final class ArtistTableData: TrackEncoding {
    var values = Set<RowArtist>()

    var statements: String {
      let artistRows = Array(values)

      artistRows.mismatchedSortableNames.forEach {
        Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
      }

      var keyStatements = artistRows.map { $0.insertStatement }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.ArtistTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(track.rowArtist)
    }
  }

  fileprivate final class AlbumTableData: TrackEncoding {
    var values = Set<RowAlbum>()

    var statements: String {
      var keyStatements = Array(values).map { $0.insertStatement }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.AlbumTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(track.rowAlbum)
    }
  }

  fileprivate final class SongTableData: TrackEncoding {
    var values = Set<RowSong>()

    var statements: String {
      var keyStatements = Array(values).map { $0.insertStatement }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.SongTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(track.rowSong)
    }
  }

  fileprivate final class PlayTableData: TrackEncoding {
    var values = Set<RowPlay>()

    func encode(_ track: Track) {
      guard let row = track.rowPlay else { return }

      values.insert(row)
    }

    var statements: String {
      var keyStatements = Array(values).map { $0.insertStatement }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.PlaysTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }
  }

  enum SQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate final class Encoder {
    let trackEncoders: [TrackEncoding]

    internal init() {
      self.trackEncoders = [
        KindTableData(), ArtistTableData(), AlbumTableData(), SongTableData(), PlayTableData(),
      ]
    }

    func encode(_ track: Track) {
      trackEncoders.forEach { $0.encode(track) }
    }

    var sqlStatements: String {
      (["PRAGMA foreign_keys = ON;"] + trackEncoders.map { $0.statements }.compactMap { $0 })
        .joined(separator: "\n")
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
