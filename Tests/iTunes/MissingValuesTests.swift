//
//  MissingValuesTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation
import Testing

@testable import iTunes

struct MissingValuesTests {
  // Absent, zero and negative numbers are all missing.
  static let numbers: [Int?] = [nil, 0, -5]

  private func track(
    discCount: Int? = 1, discNumber: Int? = 1, totalTime: Int? = 1000, trackCount: Int? = 2,
    trackNumber: Int? = 1, year: Int? = 2000
  ) -> Track {
    Track(
      album: "Album", artist: "Artist", discCount: discCount, discNumber: discNumber,
      name: "Song", persistentID: 1, totalTime: totalTime, trackCount: trackCount,
      trackNumber: trackNumber, year: year)
  }

  private func flatRow(_ track: Track) async throws -> [String: String] {
    let db = try await DatabaseFormat.flat(FlatTracksDatabaseContext(storage: .memory)).database(
      tracks: [track])
    let result = try await db.execute(
      query:
        "SELECT tracknumber, trackcount, disccount, discnumber, year, duration FROM tracks;",
      arguments: [])
    return Dictionary(
      uniqueKeysWithValues: result[0][0].map { ($0.column, "\($0.value)") })
  }

  private func laxSongsAndAlbums(_ track: Track) async throws -> [String] {
    let db = try await DatabaseFormat.normalized(
      DatabaseContext(storage: .memory, schemaOptions: .laxSchema, loggingToken: nil)
    ).database(tracks: [track])
    let result = try await db.execute(
      query: """
        SELECT s.tracknumber, al.trackcount, al.disccount, al.discnumber, s.year, s.duration
        FROM songs s JOIN albums al ON al.id = s.albumid;
        """, arguments: [])
    return result[0][0].map { "\($0.value)" }
  }

  @Test(arguments: numbers)
  func missingNumbersAreMinusOne(_ number: Int?) async throws {
    let missing = track(
      totalTime: number, trackCount: number, trackNumber: number, year: number)
    let flat = try await flatRow(missing)
    #expect(flat["tracknumber"] == "\(Int.missing)")
    #expect(flat["trackcount"] == "\(Int.missing)")
    #expect(flat["year"] == "\(Int.missing)")
    #expect(flat["duration"] == "\(Int.missing)")

    let normalized = try await laxSongsAndAlbums(missing)
    #expect(normalized[0] == "\(Int.missing)")  // track number
    #expect(normalized[1] == "\(Int.missing)")  // track count
    #expect(normalized[4] == "\(Int.missing)")  // year
    #expect(normalized[5] == "\(Int.missing)")  // duration
  }

  @Test(arguments: numbers)
  func missingDiscNumbersAreOne(_ number: Int?) async throws {
    let missing = track(discCount: number, discNumber: number)
    let flat = try await flatRow(missing)
    #expect(flat["disccount"] == "1")
    #expect(flat["discnumber"] == "1")

    let normalized = try await laxSongsAndAlbums(missing)
    #expect(normalized[2] == "1")
    #expect(normalized[3] == "1")
  }

  // A missing number fails strict generation, including a year of zero.
  @Test(arguments: [0, nil] as [Int?])
  func strictRejectsAMissingYear(_ year: Int?) async throws {
    await #expect(throws: (any Error).self) {
      _ = try await DatabaseFormat.normalized(
        DatabaseContext(storage: .memory, schemaOptions: SchemaOptions(), loggingToken: nil)
      ).database(tracks: [track(year: year)])
    }
  }
}
