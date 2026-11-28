//
//  IDChangesTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation
import Testing

@testable import iTunes

struct IDChangesTests {
  private func track(
    id: UInt, name: String = "Song", album: String = "Album", artist: String = "Artist",
    trackNumber: Int = 1, playCount: Int? = nil, playDate: String? = nil, podcast: Bool? = nil
  ) -> Track {
    Track(
      album: album, artist: artist, name: name, persistentID: id, playCount: playCount,
      playDateUTC: playDate, podcast: podcast, totalTime: 1000, trackCount: 2,
      trackNumber: trackNumber, year: 2000)
  }

  private func find(_ snapshots: [[Track]], window: Int = 3) -> [IDChange] {
    var finder = IDChangeFinder()
    for (index, tracks) in snapshots.enumerated() {
      finder.add(iTunes.Tag(tag: "t\(index + 1)", item: tracks))
    }
    return finder.changes(window: window)
  }

  private let filler = Track(
    album: "Other", artist: "Other", name: "Other", persistentID: 999, totalTime: 1000,
    trackCount: 2, trackNumber: 1, year: 2000)

  @Test func idThatStopsAndAnotherThatStartsIsAChange() {
    let changes = find([
      [track(id: 1, playCount: 5, playDate: "2026-03-01T10:21:22Z"), filler],
      [track(id: 1, playCount: 5, playDate: "2026-03-01T10:21:22Z"), filler],
      [track(id: 2, playCount: 5, playDate: "2026-03-01T10:21:22Z"), filler],
      [track(id: 2, playCount: 5, playDate: "2026-03-01T10:21:22Z"), filler],
    ])
    #expect(changes.count == 1)
    let change = changes[0]
    #expect((change.oldID, change.newID) == (1, 2))
    #expect((change.lastTag, change.firstTag, change.gap) == ("t2", "t3", 0))
    #expect(change.playsCarried)
    #expect(change.text.contains("1 -> 2"))
    #expect(change.text.contains("(carried)"))
    #expect(change.text.contains("\"Song\" by Artist on \"Album\" (track 1)"))
  }

  @Test func playsThatDidNotMoveAreNotCarried() {
    let changes = find([
      [track(id: 1, playCount: 5, playDate: "2026-03-01T10:21:22Z"), filler],
      [track(id: 2), filler],
    ])
    #expect(changes.count == 1)
    #expect(!changes[0].playsCarried)
    #expect(!changes[0].text.contains("(carried)"))
  }

  @Test func successorMustStartWithinTheWindow() {
    let snapshots = [
      [track(id: 1), filler], [filler], [filler], [filler], [filler], [track(id: 2), filler],
    ]
    #expect(find(snapshots, window: 3).isEmpty)
    let wide = find(snapshots, window: 4)
    #expect(wide.count == 1)
    #expect(wide[0].gap == 4)
  }

  @Test func twoIDsAtTheSameTimeAreNotAChange() {
    #expect(
      find([
        [track(id: 1), filler], [track(id: 1), track(id: 2), filler], [track(id: 2), filler],
      ])
      .isEmpty)
  }

  @Test func idThatIsStillInTheNewestSnapshotIsNotAChange() {
    #expect(find([[track(id: 1), filler], [track(id: 1), track(id: 2), filler]]).isEmpty)
  }

  @Test func differentTracksAreNotAChange() {
    #expect(
      find([[track(id: 1), filler], [track(id: 2, name: "Other Song"), filler]]).isEmpty)
    #expect(find([[track(id: 1), filler], [track(id: 2, trackNumber: 2), filler]]).isEmpty)
    #expect(find([[track(id: 1), filler], [track(id: 2, album: "Other Album"), filler]]).isEmpty)
    #expect(
      find([[track(id: 1), filler], [track(id: 2, artist: "Other Artist"), filler]]).isEmpty)
  }

  @Test func theNameAtTheChangeIsTheOneThatMatches() {
    // The old ID was renamed before it went, and the new ID has the new name.
    let changes = find([
      [track(id: 1, name: "Old Name"), filler], [track(id: 1, name: "New Name"), filler],
      [track(id: 2, name: "New Name"), filler],
    ])
    #expect(changes.count == 1)
    #expect(changes[0].name == "New Name")
  }

  @Test func whatIsNotMusicIsLeftOut() {
    #expect(
      find([[track(id: 1, podcast: true), filler], [track(id: 2, podcast: true), filler]]).isEmpty)
  }

  @Test func onlyTheFirstSuccessorsCount() {
    // 1 is replaced by 2, and 2 by 3. 3 is not also a successor of 1.
    let changes = find([
      [track(id: 1), filler], [track(id: 2), filler], [track(id: 3), filler],
    ])
    #expect(changes.map { [$0.oldID, $0.newID] } == [[1, 2], [2, 3]])
  }

  @Test func twoNewIDsThatStartTogetherAreBothSuccessors() {
    let changes = find([[track(id: 1), filler], [track(id: 2), track(id: 3), filler]])
    #expect(changes.map { [$0.oldID, $0.newID] } == [[1, 2], [1, 3]])
  }

  @Test func changesAreInTheOrderTheyHappened() {
    let changes = find([
      [track(id: 1), track(id: 3, name: "B"), filler], [filler, track(id: 3, name: "B")],
      [track(id: 2), filler, track(id: 4, name: "B")],
    ])
    #expect(changes.map { [$0.oldID, $0.newID] } == [[1, 2], [3, 4]])
  }
}
