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

extension String {
  var quoteEscaped: String {
    self.replacingOccurrences(of: "'", with: "''")
  }
}

extension Track {
  fileprivate var debugLogInformation: String {
    "album: \(String(describing: album)), artist: \(String(describing: artist)), kind: \(String(describing: kind)), name: \(name), podcast: \(String(describing: podcast)), trackCount: \(String(describing: trackCount)), trackNumber: \(String(describing: trackNumber)), year: \(String(describing: year))"
  }

  var artistName: String {
    guard let name = (artist ?? albumArtist ?? nil) else {
      Logger.noArtist.error("\(debugLogInformation, privacy: .public)")
      return ""
    }

    return name.quoteEscaped
  }

  var albumName: String {
    guard let album else {
      Logger.noAlbum.error("\(debugLogInformation, privacy: .public)")
      return ""
    }
    return album.quoteEscaped
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

  var dateReleasedISO8601: String {
    guard let releaseDate else { return "" }
    return releaseDate.formatted(.iso8601)
  }

  var datePlayedISO8601: String {
    guard let playDateUTC else { return "" }
    return playDateUTC.formatted(.iso8601)
  }

  var dateModifiedISO8601: String {
    guard let dateModified else { return "" }
    return dateModified.formatted(.iso8601)
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

  var songName: String {
    name.quoteEscaped
  }

  var songPlayCount: Int {
    playCount ?? 0
  }

  var artistSelect: String {
    "SELECT id FROM artists WHERE name = '\(artistName)'"
  }

  var albumSelect: String {
    "SELECT id FROM albums WHERE name = '\(albumName)' AND trackcount = \(albumTrackCount) AND disccount = \(albumDiscCount) AND discnumber = \(albumDiscNumber) AND compilation = \(albumIsCompilation)"
  }

  var kindSelect: String {
    guard let kind else { preconditionFailure("\(self)") }
    return "SELECT id FROM kinds WHERE name = '\(kind)'"
  }

  var songSelect: String {
    "SELECT id FROM songs WHERE name = '\(songName)' AND itunesid = '\(persistentID)' AND artistid = (\(artistSelect)) AND albumid = (\(albumSelect)) AND kindid = (\(kindSelect)) AND tracknumber = \(songTrackNumber) AND year = \(songYear) AND size = \(songSize) AND duration = \(songDuration) AND dateadded = '\(dateAddedISO8601)'"
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
    private var values = Set<String>()

    var statements: String {
      var keyStatements = [String]()
      keyStatements.append(Track.KindTable)
      keyStatements.append("BEGIN;")

      keyStatements.append(
        contentsOf: Array(values).map {
          "INSERT INTO kinds (name) VALUES ('\($0.quoteEscaped)');"
        })

      keyStatements.append("COMMIT;")

      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      guard let kind = track.kind else { return }

      values.insert(kind)
    }
  }

  fileprivate final class ArtistTableData: TrackEncoding {
    struct ArtistName: Hashable {
      let name: String
      let sortName: String

      init(_ track: Track) {
        self.name = track.artistName
        if let potentialSortName = (track.sortArtist ?? track.sortAlbumArtist)?.quoteEscaped {
          self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
        } else {
          self.sortName = ""
        }
      }
    }

    var values = Set<ArtistName>()

    var statements: String {
      values.reduce(into: [String: [ArtistName]]()) {
        var arr = $0[$1.name] ?? []
        arr.append($1)
        $0[$1.name] = arr
      }.filter { $0.value.count > 1 }.flatMap { $0.value }.forEach {
        Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
      }

      var keyStatements = Array(values).map {
        "INSERT INTO artists (name, sortname) VALUES ('\($0.name)', '\($0.sortName)');"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.ArtistTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(ArtistName(track))
    }
  }

  fileprivate final class AlbumTableData: TrackEncoding {
    struct Album: Hashable {
      let name: String
      let sortName: String
      let trackCount: Int
      let discCount: Int
      let discNumber: Int
      let compilation: Int

      init(_ track: Track) {
        self.name = track.albumName
        if let potentialSortName = track.sortAlbum?.quoteEscaped {
          self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
        } else {
          self.sortName = ""
        }
        self.trackCount = track.albumTrackCount
        self.discCount = track.albumDiscCount
        self.discNumber = track.albumDiscNumber
        self.compilation = track.albumIsCompilation
      }
    }

    var values = Set<Album>()

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\($0.name)', '\($0.sortName)', \($0.trackCount), \($0.discCount), \($0.discNumber), \($0.compilation));"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.AlbumTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(Album(track))
    }
  }

  fileprivate final class SongTableData: TrackEncoding {
    struct Song: Hashable {
      let name: String
      let sortName: String
      let itunesid: UInt
      let composer: String
      let trackNumber: Int
      let year: Int
      let size: UInt64
      let duration: Int
      let dateAdded: String
      let dateReleased: String
      let dateModified: String
      let comments: String
      let artistSelect: String
      let albumSelect: String
      let kindSelect: String

      init(_ track: Track) {
        self.name = track.songName
        if let potentialSortName = track.sortName?.quoteEscaped {
          self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
        } else {
          self.sortName = ""
        }
        self.itunesid = track.persistentID
        self.composer = (track.composer ?? "").quoteEscaped
        self.trackNumber = track.songTrackNumber
        self.year = track.songYear
        self.size = track.songSize
        self.duration = track.songDuration
        self.dateAdded = track.dateAddedISO8601
        self.dateReleased = track.dateReleasedISO8601
        self.dateModified = track.dateModifiedISO8601
        self.comments = (track.comments ?? "").quoteEscaped
        self.artistSelect = track.artistSelect
        self.albumSelect = track.albumSelect
        self.kindSelect = track.kindSelect
      }
    }

    var values = Set<Song>()

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, size, duration, dateadded, datereleased, datemodified, comments) VALUES ('\($0.name)', '\($0.sortName)', '\($0.itunesid)', (\($0.artistSelect)), (\($0.albumSelect)), (\($0.kindSelect)), '\($0.composer)', \($0.trackNumber), \($0.year), \($0.size), \($0.duration), '\($0.dateAdded)', '\($0.dateReleased)', '\($0.dateModified)', '\($0.comments)');"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(Track.SongTable, at: 0)
      return keyStatements.joined(separator: "\n")
    }

    func encode(_ track: Track) {
      values.insert(Song(track))
    }
  }

  fileprivate final class PlayTableData: TrackEncoding {
    fileprivate struct Play: Hashable {
      let date: String
      let delta: Int
      let songSelect: String

      init(_ track: Track) {
        self.date = track.datePlayedISO8601
        self.delta = track.playCount ?? 0
        self.songSelect = track.songSelect
      }
    }

    var values = Set<Play>()

    func encode(_ track: Track) {
      // Some tracks have play dates, but not play counts. Until that is repaired this table has a CHECK(delta >= 0) constraint.
      guard track.hasPlayed else { return }
      values.insert(Play(track))
    }

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO plays (songid, date, delta) VALUES ((\($0.songSelect)), '\($0.date)', \($0.delta));"
      }.sorted()
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
