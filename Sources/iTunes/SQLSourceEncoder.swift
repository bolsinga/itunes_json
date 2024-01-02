//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation
import os

extension Logger {
  static let noArtist = Logger(subsystem: "sql", category: "noArtist")
  static let noAlbum = Logger(subsystem: "sql", category: "noAlbum")
  static let noTrackCount = Logger(subsystem: "sql", category: "noTrackCount")
  static let noTrackNumber = Logger(subsystem: "sql", category: "noTrackNumber")
  static let badTrackNumber = Logger(subsystem: "sql", category: "badTrackNumber")
  static let noYear = Logger(subsystem: "sql", category: "noYear")
  static let duplicateArtist = Logger(subsystem: "sql", category: "duplicateArtist")
}

extension Track {
  fileprivate var debugLogInformation: String {
    "album: \(String(describing: album)), artist: \(String(describing: artist)), kind: \(String(describing: kind)), name: \(name), podcast: \(String(describing: podcast)), trackCount: \(String(describing: trackCount)), trackNumber: \(String(describing: trackNumber)), year: \(String(describing: year))"
  }

  var artistName: SortableName {
    guard let name = (artist ?? albumArtist ?? nil) else {
      Logger.noArtist.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: name, sorted: (sortArtist ?? sortAlbumArtist) ?? "")
  }

  var albumName: SortableName {
    guard let album else {
      Logger.noAlbum.error("\(debugLogInformation, privacy: .public)")
      return SortableName()
    }
    return SortableName(name: album, sorted: sortAlbum ?? "")
  }

  var albumTrackCount: Int {
    guard let trackCount else {
      Logger.noTrackCount.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackCount
  }

  var albumDiscCount: Int {
    discCount ?? 1
  }

  var albumDiscNumber: Int {
    discNumber ?? 1
  }

  var dateAddedISO8601: String {
    guard let dateAdded else { preconditionFailure() }
    return dateAdded.formatted(.iso8601)
  }

  var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }

  var songTrackNumber: Int {
    guard let trackNumber else {
      Logger.noTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    guard trackNumber > 0 else {
      Logger.badTrackNumber.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return trackNumber
  }

  var songYear: Int {
    guard let year else {
      Logger.noYear.error("\(debugLogInformation, privacy: .public)")
      return -1
    }
    return year
  }

  var songSize: UInt64 {
    size ?? 0
  }

  var songDuration: Int {
    totalTime ?? -1
  }

  var songName: SortableName {
    SortableName(name: name, sorted: sortName ?? "")
  }

  var songPlayCount: Int {
    playCount ?? 0
  }

  var artistSelect: String {
    "SELECT id FROM artists WHERE name = '\(artistName.name)'"
  }

  var albumSelect: String {
    "SELECT id FROM albums WHERE name = '\(albumName.name)' AND trackcount = \(albumTrackCount) AND disccount = \(albumDiscCount) AND discnumber = \(albumDiscNumber) AND compilation = \(albumIsCompilation)"
  }

  var kindSelect: String {
    guard let kind else { preconditionFailure("\(self)") }
    return "SELECT id FROM kinds WHERE name = '\(kind)'"
  }

  var songSelect: String {
    "SELECT id FROM songs WHERE name = '\(songName.name)' AND itunesid = '\(persistentID)' AND artistid = (\(artistSelect)) AND albumid = (\(albumSelect)) AND kindid = (\(kindSelect)) AND tracknumber = \(songTrackNumber) AND year = \(songYear) AND size = \(songSize) AND duration = \(songDuration) AND dateadded = '\(dateAddedISO8601)'"
  }

  var hasPlayed: Bool {
    // Some songs have play dates but not play counts!
    songPlayCount > 0 || !datePlayedISO8601.isEmpty
  }
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
      // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
      guard track.hasPlayed else { return }
      values.insert(RowPlay(track))
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
