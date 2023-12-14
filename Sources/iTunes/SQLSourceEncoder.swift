//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension String {
  var quoteEscaped: String {
    self.replacingOccurrences(of: "'", with: "''")
  }
}

extension Track {
  fileprivate var oldPodcastWithoutKind: Bool {
    kind == nil && (podcast != nil && podcast!)
  }

  fileprivate var shouldEncode: Bool {
    guard !oldPodcastWithoutKind else { return false }
    let kind: String = kind?.lowercased() ?? ""
    guard !kind.contains("video") else { return false }
    guard !kind.contains("pdf") else { return false }
    guard !kind.contains("itunes lp") else { return false }
    guard !kind.contains("internet audio stream") else { return false }
    return true
  }

  var artistName: String {
    (artist ?? albumArtist ?? "").quoteEscaped
  }

  var albumName: String {
    (album ?? "").quoteEscaped
  }

  var albumTrackCount: Int {
    trackCount ?? -1
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

  var albumIsCompilation: Int {
    if let compilation {
      return compilation ? 1 : 0
    }
    return 0
  }

  var songTrackNumber: Int {
    trackNumber ?? -1
  }

  var songYear: Int {
    year ?? -1
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
}

private protocol TrackEncoding {
  func encode(_ track: Track)
  var statements: String { get }
}

class SQLSourceEncoder {
  fileprivate struct KeyName: Hashable {
    let key: String
    let name: String
  }

  fileprivate final class LookupTableData: TrackEncoding {
    var values: [KeyName: Set<String>] = [:]

    static let KindKey = "kind"

    internal init() {
      [KeyName(key: SQLSourceEncoder.LookupTableData.KindKey, name: "name")].forEach {
        self.values[$0] = Set<String>()
      }
    }

    private func tableName(for keyName: KeyName) -> String {
      "\(keyName.key)s"
    }

    private func createTable(for keyName: KeyName) -> String {
      "CREATE TABLE \(tableName(for: keyName)) (id INTEGER PRIMARY KEY, \(keyName.name) TEXT NOT NULL UNIQUE);"
    }

    var statements: String {
      values.reduce(into: [String]()) { statements, kv in
        var keyStatements = Array(kv.value).map {
          "INSERT INTO \(tableName(for: kv.key)) (\(kv.key.name)) VALUES ('\($0.description.quoteEscaped)');"
        }.sorted()
        keyStatements.insert("BEGIN;", at: 0)
        keyStatements.append("COMMIT;")
        keyStatements.insert(createTable(for: kv.key), at: 0)
        statements.append(contentsOf: keyStatements)
      }.joined(separator: "\n")
    }

    private func encode(key: String, value: String) {
      values.keys.filter { key == $0.key }.forEach {
        var s = values[$0] ?? Set<String>()
        s.insert(value)
        values[$0] = s
      }
    }

    func encode(_ track: Track) {
      if let kind = track.kind {
        encode(key: SQLSourceEncoder.LookupTableData.KindKey, value: kind)
      }
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
      var keyStatements = Array(values).map {
        "INSERT INTO artists (name, sortname) VALUES ('\($0.name)', '\($0.sortName)');"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(
        "CREATE TABLE artists (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, sortname TEXT NOT NULL DEFAULT '', CHECK(length(name) > 0), CHECK(name != sortname));",
        at: 0)
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

    static let CreateTable = """
            CREATE TABLE albums (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              sortname TEXT NOT NULL DEFAULT '',
              trackcount INTEGER NOT NULL,
              disccount INTEGER NOT NULL,
              discnumber INTEGER NOT NULL,
              compilation INTEGER NOT NULL,
              UNIQUE(name, trackcount, disccount, discnumber, compilation),
              CHECK(length(name) > 0),
              CHECK(name != sortname),
              CHECK(trackcount > 0),
              CHECK(disccount > 0),
              CHECK(discnumber > 0),
              CHECK(compilation = 0 OR compilation = 1));
      """

    var values = Set<Album>()

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\($0.name)', '\($0.sortName)', \($0.trackCount), \($0.discCount), \($0.discNumber), \($0.compilation));"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(SQLSourceEncoder.AlbumTableData.CreateTable, at: 0)
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
      let trackNumber: Int
      let year: Int
      let size: UInt64
      let duration: Int
      let dateAdded: String
      let dateReleased: String
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
        self.trackNumber = track.songTrackNumber
        self.year = track.songYear
        self.size = track.songSize
        self.duration = track.songDuration
        self.dateAdded = track.dateAddedISO8601
        self.dateReleased = track.dateReleasedISO8601
        self.comments = (track.comments ?? "").quoteEscaped
        self.artistSelect = track.artistSelect
        self.albumSelect = track.albumSelect
        self.kindSelect = track.kindSelect
      }
    }

    // itunesid is TEXT since UInt is bigger than Int64 in sqlite
    static let CreateTable = """
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        sortname TEXT NOT NULL DEFAULT '',
        itunesid TEXT NOT NULL,
        artistid INTEGER NOT NULL,
        albumid INTEGER NOT NULL,
        kindid INTEGER NOT NULL,
        tracknumber INTEGER NOT NULL,
        year INTEGER NOT NULL,
        size INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        dateadded TEXT NOT NULL,
        datereleased TEXT NOT NULL DEFAULT '',
        comments TEXT NOT NULL DEFAULT '',
        UNIQUE(name, sortname, itunesid, artistid, albumid, kindid, tracknumber, year, size, duration, dateadded, datereleased, comments),
        FOREIGN KEY(artistid) REFERENCES artists(id),
        FOREIGN KEY(albumid) REFERENCES albums(id),
        FOREIGN KEY(kindid) REFERENCES kinds(id),
        CHECK(name != sortname),
        CHECK(tracknumber > 0),
        CHECK(year >= 0),
        CHECK(size > 0),
        CHECK(duration > 0));
      """

    var values = Set<Song>()

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO songs (name, sortname, itunesid, artistid, albumid, kindid, tracknumber, year, size, duration, dateadded, datereleased, comments) VALUES ('\($0.name)', '\($0.sortName)', '\($0.itunesid)', (\($0.artistSelect)), (\($0.albumSelect)), (\($0.kindSelect)), \($0.trackNumber), \($0.year), \($0.size), \($0.duration), '\($0.dateAdded)', '\($0.dateReleased)', '\($0.comments)');"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(SQLSourceEncoder.SongTableData.CreateTable, at: 0)
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

    static let CreateTable = """
      CREATE TABLE plays (
        id INTEGER PRIMARY KEY,
        songid TEXT NOT NULL,
        date TEXT NOT NULL,
        delta INTEGER NOT NULL,
        UNIQUE(songid, date, delta),
        FOREIGN KEY(songid) REFERENCES songs(id),
        CHECK(delta > 0));
      """

    var values = Set<Play>()

    func encode(_ track: Track) {
      guard track.songPlayCount > 0 else { return }
      values.insert(Play(track))
    }

    var statements: String {
      var keyStatements = Array(values).map {
        "INSERT INTO plays (songid, date, delta) VALUES ((\($0.songSelect)), '\($0.date)', \($0.delta));"
      }.sorted()
      keyStatements.insert("BEGIN;", at: 0)
      keyStatements.append("COMMIT;")
      keyStatements.insert(SQLSourceEncoder.PlayTableData.CreateTable, at: 0)
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
        LookupTableData(), ArtistTableData(), AlbumTableData(), SongTableData(), PlayTableData(),
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
    tracks.filter { $0.shouldEncode }.forEach { encoder.encode($0) }
    return encoder.sqlStatements
  }

  func encode(_ tracks: [Track]) throws -> Data {
    guard let data = try encode(tracks).data(using: .utf8) else {
      throw SQLSourceEncoderError.cannotMakeData
    }
    return data
  }
}
