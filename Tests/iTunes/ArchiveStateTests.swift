//
//  ArchiveStateTests.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation
import Testing

@testable import iTunes

struct ArchiveStateTests {
  // Minutes and seconds vary, because dates 1 to 4 whole hours apart read as the same date.
  private static let feb3 = "2026-02-03T10:11:12Z"
  private static let mar1 = "2026-03-01T10:21:22Z"
  private static let mar9 = "2026-03-09T10:31:32Z"
  private static let mar12 = "2026-03-12T10:41:42Z"

  private func track(
    id: UInt, name: String = "Song", artist: String? = "Artist", sortArtist: String? = nil,
    dateAdded: String? = "2020-01-01T00:00:00Z", releaseDate: String? = nil, playCount: Int? = nil,
    playDate: String? = nil, trackNumber: Int? = 1, trackCount: Int? = 2, year: Int? = 2000,
    totalTime: Int? = 1000
  ) -> Track {
    Track(
      album: "Album", artist: artist, dateAdded: dateAdded, name: name, persistentID: id,
      playCount: playCount, playDateUTC: playDate, releaseDate: releaseDate, sortArtist: sortArtist,
      totalTime: totalTime, trackCount: trackCount, trackNumber: trackNumber, year: year)
  }

  private func snapshot(_ tag: String, _ tracks: [Track]) -> iTunes.Tag<[Track]> {
    iTunes.Tag(tag: tag, item: tracks)
  }

  // MARK: Timeline

  @Test func firstSnapshotWritesEverything() {
    var state = ArchiveState()
    let changes = state.apply(
      snapshot(
        "t1",
        [
          track(
            id: 2, releaseDate: "2019-05-05T05:05:05Z", playCount: 12, playDate: Self.feb3),
          track(id: 1),
        ]))
    #expect(changes.tag == "t1")
    #expect(changes.songs.map(\.persistentID) == [1, 2])
    #expect(
      changes.plays == [PlayRow(persistentID: 2, date: Self.feb3, delta: 12, count: 12, tag: "t1")])
    #expect(changes.playStates == [2: PlayState(seenCount: 12, seenDate: Self.feb3)])
    #expect(changes.added.map(\.persistentID) == [1, 2])
    #expect(changes.released == [DateRow(persistentID: 2, date: "2019-05-05T05:05:05Z")])
    #expect(changes.findings.isEmpty)
    #expect(state.lastSeen == [1: "t1", 2: "t1"])
  }

  @Test func laterSnapshotAddsTheDelta() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 40, playDate: Self.mar1)]))
    let changes = state.apply(snapshot("t2", [track(id: 1, playCount: 43, playDate: Self.mar9)]))
    #expect(
      changes.plays == [PlayRow(persistentID: 1, date: Self.mar9, delta: 3, count: 43, tag: "t2")])
    #expect(changes.added.isEmpty)
    #expect(changes.findings.isEmpty)
  }

  @Test func resetKeepsTheTotalGrowing() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 40, playDate: Self.mar1)]))
    let changes = state.apply(snapshot("t2", [track(id: 1, playCount: 3, playDate: Self.mar9)]))
    #expect(changes.plays.map(\.delta) == [3])
    #expect(changes.plays.map(\.count) == [43])
    #expect(changes.findings.map(\.code) == ["countReset"])
    #expect(changes.findings.first?.persistentID == 1)
  }

  @Test func totalIsTheRunningSumOfDeltas() {
    var state = ArchiveState()
    var plays = [PlayRow]()
    let steps: [(Int, String)] = [(5, Self.feb3), (7, Self.mar1), (2, Self.mar9), (3, Self.mar12)]
    for (index, step) in steps.enumerated() {
      plays +=
        state.apply(
          snapshot("t\(index)", [track(id: 1, playCount: step.0, playDate: step.1)])
        ).plays
    }
    var sum = 0
    for play in plays {
      sum += play.delta
      #expect(play.count == sum)
      #expect(play.count >= play.delta)
    }
    #expect(state.playTotals[1] == sum)
  }

  @Test func playStateIsNotInTheChangesWhenItDoesNotChange() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 40, playDate: Self.mar1)]))
    let changes = state.apply(snapshot("t2", [track(id: 1, playCount: 40, playDate: Self.mar1)]))
    #expect(changes.playStates.isEmpty)
    #expect(changes.plays.isEmpty)
  }

  @Test func addedAndReleasedKeepTheFirstValue() {
    var state = ArchiveState()
    _ = state.apply(
      snapshot("t1", [track(id: 1, dateAdded: "2020-01-01T00:00:00Z", releaseDate: nil)]))
    let changes = state.apply(
      snapshot(
        "t2",
        [track(id: 1, dateAdded: "2020-01-01T00:00:00Z", releaseDate: "2018-02-02T02:02:02Z")]))
    #expect(changes.added.isEmpty)
    #expect(changes.released == [DateRow(persistentID: 1, date: "2018-02-02T02:02:02Z")])
    let later = state.apply(
      snapshot("t3", [track(id: 1, releaseDate: "2001-01-01T01:01:01Z")]))
    #expect(later.released.isEmpty)
    #expect(state.released[1] == "2018-02-02T02:02:02Z")
  }

  @Test func dateAddedChangeIsAFinding() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, dateAdded: "2020-01-01T00:00:01Z")]))
    let changes = state.apply(snapshot("t2", [track(id: 1, dateAdded: "2021-06-01T00:07:01Z")]))
    #expect(changes.added.isEmpty)
    #expect(changes.findings.map(\.code) == ["dateAddedChanged"])
    #expect(state.added[1] == "2020-01-01T00:00:01Z")
  }

  @Test func dateAddedChangeIsNotWrittenAgainAtADaylightSavingChange() {
    var state = ArchiveState()
    func written(_ tag: String, _ dateAdded: String) -> [String] {
      state.apply(snapshot(tag, [track(id: 1, dateAdded: dateAdded)])).findings.map(\.detail)
    }
    let first = "2020-01-01T00:00:01Z"
    #expect(written("t1", first).isEmpty)
    // A real change.
    let changed = "2021-06-01T00:07:01Z"
    #expect(written("t2", changed) == ["first \(first), now \(changed)"])
    // The daylight saving changes move it by an hour, back and forth, and it is the same change.
    #expect(written("t3", "2021-06-01T01:07:01Z").isEmpty)
    #expect(written("t4", changed).isEmpty)
    #expect(written("t5", "2021-05-31T23:07:01Z").isEmpty)
    // Seconds are a different change, and so is a day.
    #expect(written("t6", "2021-06-01T01:07:05Z").count == 1)
    #expect(written("t7", "2021-06-02T01:07:05Z").count == 1)
    // And it is written once for the new date.
    #expect(written("t8", "2021-06-02T02:07:05Z").isEmpty)
  }

  @Test func dateAddedMovedByWholeHoursIsNotAFinding() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, dateAdded: "2020-01-01T00:00:01Z")]))
    let changes = state.apply(snapshot("t2", [track(id: 1, dateAdded: "2020-01-01T01:00:01Z")]))
    #expect(changes.findings.isEmpty)
  }

  @Test func sharedPlayDateIsAFindingForTheLaterSong() {
    var state = ArchiveState()
    let changes = state.apply(
      snapshot(
        "t1",
        [
          track(id: 2, playCount: 1, playDate: Self.feb3),
          track(id: 1, playCount: 1, playDate: Self.feb3),
        ]))
    #expect(changes.plays.count == 2)
    let shared = changes.findings.filter { $0.code == "sharedPlayDate" }
    #expect(shared.map(\.persistentID) == [2])
    #expect(shared.first?.detail.contains("1") == true)
    // The date is stored as it is for both songs.
    #expect(Set(changes.plays.map(\.date)) == [Self.feb3])
  }

  @Test func songThatIsNoLongerInTheSnapshotKeepsItsState() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 5, playDate: Self.mar1)]))
    let changes = state.apply(snapshot("t2", [track(id: 2)]))
    #expect(changes.songs.map(\.persistentID) == [2])
    #expect(state.lastSeen[1] == "t1")
    #expect(state.playStates[1] == PlayState(seenCount: 5, seenDate: Self.mar1))
    let back = state.apply(snapshot("t3", [track(id: 1, playCount: 6, playDate: Self.mar9)]))
    #expect(back.plays.map(\.delta) == [1])
    #expect(state.lastSeen[1] == "t3")
  }

  @Test func onlyMusicIsArchived() {
    var state = ArchiveState()
    var podcast = track(id: 2, playCount: 3, playDate: Self.feb3)
    podcast.podcast = true
    var noArtist = track(id: 3, artist: nil)
    noArtist.albumArtist = nil
    let changes = state.apply(snapshot("t1", [track(id: 1), podcast, noArtist]))
    #expect(changes.songs.map(\.persistentID) == [1])
    #expect(changes.plays.isEmpty)
    #expect(changes.findings.isEmpty)
    #expect(state.lastSeen == [1: "t1"])
  }

  // MARK: Invalid tracks

  @Test func invalidTrackIsLeftOutAndReportedOnce() {
    var state = ArchiveState()
    let first = state.apply(
      snapshot("t1", [track(id: 1, playCount: 3, playDate: Self.mar1, year: 0)]))
    #expect(first.songs.isEmpty)
    #expect(first.plays.isEmpty)
    #expect(first.added.isEmpty)
    #expect(first.findings.map(\.code) == ["invalidTrack"])
    let second = state.apply(
      snapshot("t2", [track(id: 1, playCount: 4, playDate: Self.mar9, year: 0)]))
    #expect(second.findings.isEmpty)
    #expect(state.lastSeen[1] == nil)
  }

  @Test func invalidNumberTakesTheNewestValidValue() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, year: 1999)]))
    let changes = state.apply(snapshot("t2", [track(id: 1, year: 0)]))
    #expect(changes.songs.first?.year == 1999)
    #expect(changes.findings.isEmpty)
  }

  @Test func numbersThatWereValidInDifferentSnapshotsAreCombined() {
    var state = ArchiveState()
    let first = state.apply(snapshot("t1", [track(id: 1, trackCount: nil, year: 1999)]))
    #expect(first.songs.isEmpty)
    let second = state.apply(snapshot("t2", [track(id: 1, trackCount: 9, year: 0)]))
    #expect(second.songs.first?.year == 1999)
    #expect(second.songs.first?.trackCount == 9)
  }

  @Test func invalidTrackThatIsFixedGetsItsHistoryFolded() {
    var state = ArchiveState()
    let first = state.apply(
      snapshot(
        "t1",
        [
          track(
            id: 1, dateAdded: "2019-01-01T00:00:01Z", releaseDate: "2001-02-03T04:05:06Z",
            playCount: 5, playDate: Self.feb3, year: 0)
        ]))
    #expect(first.plays.isEmpty)
    #expect(first.pending[1]?.observations.count == 1)
    _ = state.apply(
      snapshot("t2", [track(id: 1, playCount: 6, playDate: Self.mar1, year: 0)]))
    // Fixed in Music, and the older snapshots are still as they were.
    let fixed = state.apply(
      snapshot(
        "t3", [track(id: 1, dateAdded: "2021-01-01T00:07:01Z", playCount: 7, playDate: Self.mar9)]))
    #expect(
      fixed.plays == [
        PlayRow(persistentID: 1, date: Self.feb3, delta: 5, count: 5, tag: "t1"),
        PlayRow(persistentID: 1, date: Self.mar1, delta: 1, count: 6, tag: "t2"),
        PlayRow(persistentID: 1, date: Self.mar9, delta: 1, count: 7, tag: "t3"),
      ])
    #expect(fixed.playStates == [1: PlayState(seenCount: 7, seenDate: Self.mar9)])
    // The first dates are the first the track had.
    #expect(fixed.added == [DateRow(persistentID: 1, date: "2019-01-01T00:00:01Z")])
    #expect(fixed.released == [DateRow(persistentID: 1, date: "2001-02-03T04:05:06Z")])
    #expect(fixed.findings.map(\.code) == ["dateAddedChanged"])
    #expect(fixed.pending.isEmpty)
    #expect(state.pending.isEmpty)
  }

  @Test func whatAnInvalidTrackShowsIsKeptOnlyWhenItChanges() {
    var state = ArchiveState()
    // Nothing is shown yet.
    _ = state.apply(snapshot("t1", [track(id: 1, year: 0)]))
    #expect(state.pending[1]?.observations.isEmpty == true)
    _ = state.apply(snapshot("t2", [track(id: 1, playCount: 5, playDate: Self.feb3, year: 0)]))
    _ = state.apply(snapshot("t3", [track(id: 1, playCount: 5, playDate: Self.feb3, year: 0)]))
    _ = state.apply(snapshot("t4", [track(id: 1, playCount: 6, playDate: Self.mar1, year: 0)]))
    #expect(
      state.pending[1]?.observations == [
        PendingTrack.Observation(tag: "t2", count: 5, date: Self.feb3),
        PendingTrack.Observation(tag: "t4", count: 6, date: Self.mar1),
      ])
  }

  @Test func replayedObservationsKeepTheirOwnTags() {
    var state = ArchiveState()
    // No play date at first, then one.
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 5, playDate: nil, year: 0)]))
    _ = state.apply(snapshot("t2", [track(id: 1, playCount: 5, playDate: Self.feb3, year: 0)]))
    let fixed = state.apply(snapshot("t3", [track(id: 1, playCount: 5, playDate: Self.feb3)]))
    #expect(
      fixed.plays == [PlayRow(persistentID: 1, date: Self.feb3, delta: 5, count: 5, tag: "t2")])
    let noPlayDate = fixed.findings.filter { $0.code == "noPlayDate" }
    #expect(noPlayDate.map(\.tag) == ["t1"])
  }

  @Test func invalidTrackWithNoFixKeepsWhatItShowedAndAddsNoPlays() {
    var state = ArchiveState()
    let changes = state.apply(
      snapshot("t1", [track(id: 1, playCount: 5, playDate: Self.feb3, year: 0)]))
    #expect(changes.plays.isEmpty)
    #expect(changes.playStates.isEmpty)
    #expect(changes.pending.keys.sorted() == [1])
    #expect(state.playStates.isEmpty)
  }

  // MARK: Findings

  @Test func repeatedSongFindingIsWrittenOnce() {
    var state = ArchiveState()
    _ = state.apply(snapshot("t1", [track(id: 1, playCount: 40, playDate: Self.mar1)]))
    let second = state.apply(snapshot("t2", [track(id: 1, playCount: 43, playDate: nil)]))
    #expect(second.findings.map(\.code) == ["countUpDateNotForward"])
    #expect(second.findings.first?.tag == "t2")
    let third = state.apply(snapshot("t3", [track(id: 1, playCount: 43, playDate: nil)]))
    #expect(third.findings.isEmpty)
    // A different observation is a new finding.
    let fourth = state.apply(snapshot("t4", [track(id: 1, playCount: 44, playDate: nil)]))
    #expect(fourth.findings.map(\.code) == ["countUpDateNotForward"])
    // And the baseline did not move, so a good observation counts all the plays.
    let fifth = state.apply(snapshot("t5", [track(id: 1, playCount: 44, playDate: Self.mar12)]))
    #expect(fifth.plays.map(\.delta) == [4])
  }

  @Test func findingsWithDifferentCodesDoNotHideEachOther() {
    var state = ArchiveState()
    func tracks() -> [Track] {
      [track(id: 1, dateAdded: "2021-06-01T00:07:01Z", playCount: 8, playDate: nil)]
    }
    _ = state.apply(
      snapshot(
        "t1", [track(id: 1, dateAdded: "2020-01-01T00:00:01Z", playCount: 5, playDate: Self.mar1)]))
    // Two findings that go on in every later snapshot are each written once.
    let second = state.apply(snapshot("t2", tracks()))
    #expect(Set(second.findings.map(\.code)) == ["dateAddedChanged", "countUpDateNotForward"])
    let third = state.apply(snapshot("t3", tracks()))
    #expect(third.findings.isEmpty)
  }

  @Test func findingNotAboutASongIsWrittenOncePerRun() {
    var state = ArchiveState()
    func tracks(filled: Bool) -> [Track] {
      [
        track(id: 1, artist: "A", sortArtist: filled ? "A, The" : nil),
        track(id: 2, artist: "A", sortArtist: "A, The"),
      ]
    }
    let first = state.apply(snapshot("t1", tracks(filled: false)))
    #expect(first.findings.map(\.code) == ["sortNameFilled"])
    #expect(first.findings.first?.persistentID == nil)
    let second = state.apply(snapshot("t2", tracks(filled: false)))
    #expect(second.findings.isEmpty)
    // Fixed in Music.
    let fixed = state.apply(snapshot("t3", tracks(filled: true)))
    #expect(fixed.findings.isEmpty)
    // And broken again, which is new.
    let again = state.apply(snapshot("t4", tracks(filled: false)))
    #expect(again.findings.map(\.code) == ["sortNameFilled"])
  }

  @Test func albumFindingsAreIncluded() {
    var state = ArchiveState()
    var one = track(id: 1)
    one.compilation = true
    one.albumArtist = nil
    let changes = state.apply(snapshot("t1", [one]))
    #expect(changes.findings.map(\.code) == ["compilationNoAlbumArtist"])
    #expect(changes.findings.first?.persistentID == 1)
  }

  @Test func duplicateIDIsReportedAndOnePlayIsFolded() {
    var state = ArchiveState()
    let changes = state.apply(
      snapshot(
        "t1",
        [
          track(
            id: 1, name: "A", dateAdded: "2020-01-01T00:00:00Z", playCount: 2, playDate: Self.feb3),
          track(
            id: 1, name: "B", dateAdded: "2021-01-01T00:00:00Z", playCount: 9, playDate: Self.mar1),
        ]))
    #expect(changes.findings.map(\.code) == ["duplicatePersistentID"])
    #expect(changes.plays.map(\.count) == [2])
  }

  // MARK: Finding

  @Test func findingExposesTheTableColumns() {
    let play = PlayFinding(
      code: .countReset, before: PlayState(seenCount: 40, seenDate: Self.mar1),
      observation: PlayObservation(count: 3, date: Self.mar9), playsAdded: 3,
      after: PlayState(seenCount: 3, seenDate: Self.mar9))
    let finding = Finding.play(persistentID: 7, play)
    #expect(finding.persistentID == 7)
    #expect(finding.code == "countReset")
    #expect(finding.detail.contains("before=(40, \(Self.mar1))"))
    #expect(finding.detail.contains("observation=(3, \(Self.mar9))"))
    #expect(finding.detail.contains("playsAdded=3"))
    #expect(finding.detail.contains("after=(3, \(Self.mar9))"))
    #expect(!finding.detail.contains("tag"))
  }
}
