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
  enum Kind: CaseIterable {
    case strict, lax, flat
  }

  // Absent, zero and negative numbers are all missing.
  static let numbers: [Int?] = [nil, 0, -5]

  private func track(
    id: UInt = 1, discCount: Int? = 1, discNumber: Int? = 1, totalTime: Int? = 1000,
    trackCount: Int? = 2, trackNumber: Int? = 1, year: Int? = 2000
  ) -> Track {
    Track(
      album: "Album", artist: "Artist", discCount: discCount, discNumber: discNumber,
      name: "Song \(id)", persistentID: id, totalTime: totalTime, trackCount: trackCount,
      trackNumber: trackNumber, year: year)
  }

  private func database(_ kind: Kind, _ tracks: [Track]) async throws -> Database {
    switch kind {
    case .strict:
      try await DatabaseFormat.normalized(
        DatabaseContext(storage: .memory, schemaOptions: SchemaOptions(), loggingToken: nil)
      ).database(tracks: tracks)
    case .lax:
      try await DatabaseFormat.normalized(
        DatabaseContext(storage: .memory, schemaOptions: .laxSchema, loggingToken: nil)
      ).database(tracks: tracks)
    case .flat:
      try await DatabaseFormat.flat(FlatTracksDatabaseContext(storage: .memory))
        .database(tracks: tracks)
    }
  }

  // No database holds a made-up value: a track without a track number, track count, year or
  // duration is an error, with strict, lax and flat databases.
  @Test(arguments: Kind.allCases, numbers)
  func missingNumbersAreRejected(_ kind: Kind, _ number: Int?) async throws {
    let fields: [Track] = [
      track(trackNumber: number), track(trackCount: number), track(totalTime: number),
      track(year: number),
    ]
    for missing in fields {
      await #expect(throws: MissingValuesError.self) {
        _ = try await database(kind, [track(id: 2), missing])
      }
    }
  }

  @Test func errorNamesEveryTrackAndField() {
    let tracks = [track(id: 5, trackCount: nil, year: 0), track(id: 6), track(id: 7, totalTime: 0)]
    #expect(throws: MissingValuesError.self) { try tracks.requireCompleteNumbers() }
    do {
      try tracks.requireCompleteNumbers()
    } catch let error as MissingValuesError {
      #expect(
        error.entries == [
          .init(persistentID: 5, name: "Song 5", fields: ["track count", "year"]),
          .init(persistentID: 7, name: "Song 7", fields: ["duration"]),
        ])
    } catch {
      Issue.record("\(error)")
    }
  }

  // A disc count or disc number that Music leaves out, or sets to zero, is 1.
  @Test(arguments: Kind.allCases, numbers)
  func missingDiscNumbersAreOne(_ kind: Kind, _ number: Int?) async throws {
    let db = try await database(kind, [track(discCount: number, discNumber: number)])
    let query =
      kind == .flat
      ? "SELECT disccount, discnumber FROM tracks;"
      : "SELECT disccount, discnumber FROM albums;"
    let rows = try await db.execute(query: query, arguments: [])
    #expect(rows[0][0].map { $0.value.integer } == [1, 1])
  }
}
