//
//  ArchiveReader.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation

extension Database {
  /// The state to apply the next snapshot to, read from the tables. It is equal to the state that
  /// applying every snapshot so far, in one run, leaves, so an update gives what a rebuild gives.
  ///
  /// Most of it is in the tables. What is not is in `archivestate`: the findings that are not
  /// about a song and that the last snapshot had, and the required numbers of a song that has no
  /// row.
  func loadArchiveState() throws -> ArchiveState {
    try transaction { db in try db.readState() }
  }
}

extension Database {
  fileprivate func rows(_ sql: String) throws -> [[Value]] {
    let statement = try prepare(sql)
    defer { statement.close() }
    return try run(statement, []).map { $0.map(\.value) }
  }

  fileprivate func readState() throws -> ArchiveState {
    var state = ArchiveState()

    for row in try rows("SELECT itunesid, seencount, seendate FROM playstate") {
      guard let id = row[0].persistentID, let count = row[1].integer, let date = row[2].string
      else { continue }
      state.playStates[id] = PlayState(seenCount: Int(count), seenDate: date)
    }
    for row in try rows("SELECT itunesid, MAX(count) FROM plays GROUP BY itunesid") {
      guard let id = row[0].persistentID, let count = row[1].integer else { continue }
      state.playTotals[id] = Int(count)
    }
    for row in try rows("SELECT itunesid, date FROM added") {
      guard let id = row[0].persistentID, let date = row[1].string else { continue }
      state.added[id] = date
    }
    for row in try rows("SELECT itunesid, date FROM released") {
      guard let id = row[0].persistentID, let date = row[1].string else { continue }
      state.released[id] = date
    }
    for row in try rows(
      """
      SELECT s.itunesid, s.lastseen, s.tracknumber, al.trackcount, s.year, s.duration
      FROM songs s JOIN albums al ON al.id = s.albumid
      """)
    {
      guard let id = row[0].persistentID, let lastSeen = row[1].string else { continue }
      state.lastSeen[id] = lastSeen
      state.attributes[id] = CatalogAttributes(
        trackNumber: row[2].integer.map(Int.init), trackCount: row[3].integer.map(Int.init),
        year: row[4].integer.map(Int.init), duration: row[5].integer.map(Int.init))
    }
    // The first song that has a play at a date is the one whose play was written first.
    for row in try rows(
      "SELECT date, itunesid FROM plays WHERE id IN (SELECT MIN(id) FROM plays GROUP BY date)")
    {
      guard let date = row[0].string, let id = row[1].persistentID else { continue }
      state.playDateOwners[date] = id
    }
    // A finding is only written when it differs from the last one of its song and code.
    for row in try rows(
      """
      SELECT itunesid, code, detail FROM findings
      WHERE id IN (SELECT MAX(id) FROM findings WHERE itunesid IS NOT NULL GROUP BY itunesid, code)
      """)
    {
      guard let id = row[0].persistentID, let code = row[1].string, let detail = row[2].string
      else { continue }
      state.lastDetails[ArchiveState.SongFindingKey(persistentID: id, code: code)] = detail
    }

    let decoder = JSONDecoder()
    if let text = try readArchiveState(ArchiveState.activeFindingsKey) {
      state.activeOtherFindings = Set(
        try decoder.decode([ArchiveState.OtherFindingKey].self, from: Data(text.utf8)))
    }
    if let text = try readArchiveState(ArchiveState.partialAttributesKey) {
      for (key, attributes) in try decoder.decode(
        [String: CatalogAttributes].self, from: Data(text.utf8))
      {
        guard let id = UInt(key) else { continue }
        state.attributes[id] = attributes
      }
    }
    return state
  }
}

extension Database.Value {
  /// The persistent ID in an `itunesid` column.
  fileprivate var persistentID: UInt? {
    string.flatMap { UInt($0) }
  }
}
