//
//  SQLSourceEncoder.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Track {
  fileprivate var shouldEncode: Bool {
    let kind: String = kind?.lowercased() ?? ""
    guard !kind.contains("video") else { return false }
    guard !kind.contains("pdf") else { return false }
    guard !kind.contains("itunes lp") else { return false }
    return true
  }
}

extension String {
  var quoteEscaped: String {
    self.replacingOccurrences(of: "'", with: "''")
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
    static let GenreKey = "genre"

    internal init() {
      [
        KeyName(key: SQLSourceEncoder.LookupTableData.KindKey, name: "name"),
        KeyName(key: SQLSourceEncoder.LookupTableData.GenreKey, name: "name"),
      ].forEach { self.values[$0] = Set<String>() }
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
      if let genre = track.genre {
        encode(key: SQLSourceEncoder.LookupTableData.GenreKey, value: genre)
      }
    }
  }

  fileprivate final class ArtistTableData: TrackEncoding {
    struct ArtistName: Hashable {
      let name: String
      let sortName: String

      init(_ track: Track) {
        self.name = (track.artist ?? track.albumArtist ?? "").quoteEscaped
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
      let compilation: Bool

      init(_ track: Track) {
        self.name = (track.album ?? "").quoteEscaped
        if let potentialSortName = track.sortAlbum?.quoteEscaped {
          self.sortName = (self.name != potentialSortName) ? potentialSortName : ""
        } else {
          self.sortName = ""
        }
        self.trackCount = track.trackCount ?? -1
        self.discCount = track.discCount ?? 1
        self.discNumber = track.discNumber ?? 1
        self.compilation = track.compilation ?? false
      }

      var compilationValue: Int {
        compilation ? 1 : 0
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
        "INSERT INTO albums (name, sortname, trackcount, disccount, discnumber, compilation) VALUES ('\($0.name)', '\($0.sortName)', \($0.trackCount), \($0.discCount), \($0.discNumber), \($0.compilationValue));"
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

  enum SQLSourceEncoderError: Error {
    case cannotMakeData
  }

  fileprivate final class Encoder {
    let trackEncoders: [TrackEncoding]

    internal init() {
      self.trackEncoders = [LookupTableData(), ArtistTableData(), AlbumTableData()]
    }

    func encode(_ track: Track) {
      trackEncoders.forEach { $0.encode(track) }
    }

    var sqlStatements: String {
      trackEncoders.map { $0.statements }.compactMap { $0 }.joined(separator: "\n")
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
