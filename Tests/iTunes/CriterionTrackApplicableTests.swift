//
//  CriterionTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class CriterionTrackApplicableTests: XCTestCase {
  private var albumArtistCriterion: Set<Criterion> {
    [.album("l"), .artist("a")]
  }

  private var albumSongCriterion: Set<Criterion> {
    [.album("l"), .song("s")]
  }

  private var artistSongCriterion: Set<Criterion> {
    [.artist("a"), .song("s")]
  }

  private var albumArtistSongCriterion: Set<Criterion> {
    [.album("l"), .artist("a"), .song("s")]
  }

  private var albumArtistPlayCountCriterion: Set<Criterion> {
    [.album("l"), .artist("a"), .playCount(3)]
  }

  private var albumSongPlayCountCriterion: Set<Criterion> {
    [.album("l"), .song("s"), .playCount(3)]
  }

  private var artistSongPlayCountCriterion: Set<Criterion> {
    [.artist("a"), .song("s"), .playCount(3)]
  }

  private var albumPlayCountCriterion: Set<Criterion> {
    [.album("l"), .playCount(3)]
  }

  private var artistPlayCountCriterion: Set<Criterion> {
    [.artist("a"), .playCount(3)]
  }

  private var songPlayCountCriterion: Set<Criterion> {
    [.song("s"), .playCount(3)]
  }

  private var allCriterion: Set<Criterion> {
    [.album("l"), .artist("a"), .song("s"), .playCount(3)]
  }

  func testSong() throws {
    let t = Track(name: "s", persistentID: 0)

    XCTAssertFalse(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.playCount(3)]))
    XCTAssertFalse(t.criteriaApplies(albumArtistCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumSong() throws {
    let t = Track(album: "l", name: "s", persistentID: 0)

    XCTAssertTrue(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.playCount(3)]))
    XCTAssertFalse(t.criteriaApplies(albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistSong() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    XCTAssertTrue(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.playCount(3)]))
    XCTAssertTrue(t.criteriaApplies(albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongCriterion))
    XCTAssertTrue(t.criteriaApplies(artistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistPlayCountSong() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0, playCount: 3)

    XCTAssertTrue(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.playCount(3)]))
    XCTAssertTrue(t.criteriaApplies(albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongCriterion))
    XCTAssertTrue(t.criteriaApplies(artistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(albumArtistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(albumArtistPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(artistSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(albumPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(artistPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(songPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }
}
