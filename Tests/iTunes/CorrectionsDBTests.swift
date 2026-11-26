//
//  CorrectionsDBTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Testing

@testable import iTunes

struct CorrectionsDBTests {
  // One repair for each kind of correction.
  static let repairs: [IdentityRepair] = [
    IdentityRepair(persistentID: 1, correction: .duration(123_456)),
    IdentityRepair(persistentID: 2, correction: .persistentID(22)),
    IdentityRepair(persistentID: 3, correction: .dateAdded("2003-12-15T17:02:56Z")),
    IdentityRepair(persistentID: 4, correction: .composer("A Composer")),
    IdentityRepair(persistentID: 5, correction: .comments("Some comments")),
    IdentityRepair(persistentID: 6, correction: .dateReleased("2003-12-15T17:02:56Z")),
    IdentityRepair(
      persistentID: 7, correction: .albumTitle(SortableName(name: "The Album", sorted: "Album"))),
    IdentityRepair(persistentID: 8, correction: .year(1999)),
    IdentityRepair(persistentID: 9, correction: .trackNumber(4)),
    IdentityRepair(
      persistentID: 10,
      correction: .replaceSongTitle(SortableName(name: "The Song", sorted: "Song"))
    ),
    IdentityRepair(persistentID: 11, correction: .discCount(2)),
    IdentityRepair(persistentID: 12, correction: .discNumber(1)),
    IdentityRepair(
      persistentID: 13, correction: .artist(SortableName(name: "The Artist", sorted: "Artist"))),
    IdentityRepair(
      persistentID: 14,
      correction: .play(
        old: Play(date: "2003-12-15T17:02:56Z", count: 3),
        new: Play(date: "2004-01-01T00:00:00Z", count: 4))),
  ]

  // A correction written to a patch .db file must read back unchanged.
  @Test(arguments: repairs)
  func roundTrip(repair: IdentityRepair) async throws {
    let encoder = try FlatDBEncoder(context: CorrectionsDBContext(storage: .memory))
    try await encoder.encode(items: [repair])
    let readBack = try await encoder.db.identityRepairs()
    #expect(readBack == [repair])
  }
}
