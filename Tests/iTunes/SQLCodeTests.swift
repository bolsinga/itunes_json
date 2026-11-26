//
//  SQLCodeTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation
import Testing

@testable import iTunes

struct SQLCodeTests {
  private func track(
    id: UInt, name: String, artist: String, album: String, albumArtist: String? = nil,
    trackNumber: Int, trackCount: Int, compilation: Bool? = nil
  ) -> Track {
    Track(
      album: album, albumArtist: albumArtist, artist: artist, compilation: compilation,
      discCount: 1, discNumber: 1, name: name, persistentID: id, totalTime: 1000,
      trackCount: trackCount, trackNumber: trackNumber, year: 2000)
  }

  private var tracks: [Track] {
    [
      // An album with several tracks is one album.
      track(
        id: 1, name: "One", artist: "Solo Artist", album: "Solo", trackNumber: 1, trackCount: 3),
      track(
        id: 2, name: "Two", artist: "Solo Artist", album: "Solo", trackNumber: 2, trackCount: 3),
      track(
        id: 3, name: "Three", artist: "Solo Artist", album: "Solo", trackNumber: 3, trackCount: 3),

      // Two artists have an album with the same name and counts. They are two albums.
      track(
        id: 4, name: "Hit A", artist: "Artist A", album: "Greatest Hits", trackNumber: 1,
        trackCount: 2),
      track(
        id: 5, name: "Hit A2", artist: "Artist A", album: "Greatest Hits", trackNumber: 2,
        trackCount: 2),
      track(
        id: 6, name: "Hit B", artist: "Artist B", album: "Greatest Hits", trackNumber: 1,
        trackCount: 2),
      track(
        id: 7, name: "Hit B2", artist: "Artist B", album: "Greatest Hits", trackNumber: 2,
        trackCount: 2),

      // The artist is part of an album's identity, so tracks of one album name with different
      // artists are different albums.
      track(
        id: 8, name: "Mix 1", artist: "Artist D", album: "Mixtape", albumArtist: "Various Artists",
        trackNumber: 1, trackCount: 3, compilation: true),
      track(
        id: 9, name: "Mix 2", artist: "Artist C", album: "Mixtape", albumArtist: "Various Artists",
        trackNumber: 2, trackCount: 3, compilation: true),
      track(
        id: 10, name: "Mix 3", artist: "Artist E", album: "Mixtape", albumArtist: "Various Artists",
        trackNumber: 3, trackCount: 3, compilation: true),
    ]
  }

  private let query = """
    SELECT s.itunesid, s.name, sa.name, al.name, al.trackcount, al.compilation, aa.name
    FROM songs s
    JOIN artists sa ON sa.id = s.artistid
    JOIN albums al ON al.id = s.albumid
    JOIN artists aa ON aa.id = al.artistid
    ORDER BY CAST(s.itunesid AS INTEGER);
    """

  private func summary(of db: Database) async throws -> [String] {
    let albums = try await db.execute(query: "SELECT COUNT(*) FROM albums;", arguments: [])
    let songs = try await db.execute(query: query, arguments: [])
    return (albums + songs).flatMap { $0 }.map { row in
      row.map { "\($0.value)" }.joined(separator: "|")
    }
  }

  private func databaseFromRows(_ tracks: [Track], _ schemaOptions: SchemaOptions) async throws
    -> Database
  {
    try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: schemaOptions, loggingToken: nil)
    ).database(tracks: tracks)
  }

  private func databaseFromSQLCode(_ tracks: [Track], _ schemaOptions: SchemaOptions) async throws
    -> Database
  {
    let data = try tracks.sqlData(
      SQLCodeContext(output: .standardOut, schemaOptions: schemaOptions, loggingToken: nil))
    let db = try Database(context: Database.Context(storage: .memory, loggingToken: nil))
    // This stops at the first statement that fails, which fails the test.
    try await db.execute(String(decoding: data, as: UTF8.self))
    return db
  }

  // Strict and lax albums.
  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func sqlCodeHasOneRowForEachAlbum(_ schemaOptions: SchemaOptions) async throws {
    let db = try await databaseFromSQLCode(tracks, schemaOptions)
    let albums = try await db.execute(query: "SELECT COUNT(*) FROM albums;", arguments: [])
    let count = "\(albums[0][0][0].value)"
    #expect(count == "6", "albums: \(count)")
  }

  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func songsAreInTheirOwnArtistsAlbum(_ schemaOptions: SchemaOptions) async throws {
    let db = try await databaseFromSQLCode(tracks, schemaOptions)
    let rows = try await db.execute(
      query: """
        SELECT s.name, aa.name FROM songs s
        JOIN albums al ON al.id = s.albumid
        JOIN artists aa ON aa.id = al.artistid
        WHERE al.name = 'Greatest Hits' ORDER BY s.name;
        """, arguments: [])
    let pairs = rows[0].map { $0.map { "\($0.value)" }.joined(separator: "|") }
    #expect(pairs == ["Hit A|Artist A", "Hit A2|Artist A", "Hit B|Artist B", "Hit B2|Artist B"])
  }

  @Test(arguments: [SchemaOptions(), SchemaOptions.laxSchema])
  func sqlCodeMatchesTheDatabase(_ schemaOptions: SchemaOptions) async throws {
    let fromRows = try await summary(of: try await databaseFromRows(tracks, schemaOptions))
    let fromSQL = try await summary(of: try await databaseFromSQLCode(tracks, schemaOptions))
    #expect(fromSQL == fromRows)
  }
}
