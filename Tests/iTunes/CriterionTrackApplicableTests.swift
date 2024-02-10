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

  private var allCriterion: Set<Criterion> {
    [.album("l"), .artist("a"), .song("s")]
  }

  func testSong() throws {
    let t = Track(name: "s", persistentID: 0)

    XCTAssertFalse(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertFalse(t.criteriaApplies(albumArtistCriterion))
    XCTAssertFalse(t.criteriaApplies(albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumSong() throws {
    let t = Track(album: "l", name: "s", persistentID: 0)

    XCTAssertTrue(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertFalse(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertFalse(t.criteriaApplies(albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistSong() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    XCTAssertTrue(t.criteriaApplies([Criterion.album("l")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.artist("a")]))
    XCTAssertTrue(t.criteriaApplies([Criterion.song("s")]))
    XCTAssertTrue(t.criteriaApplies(albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(albumSongCriterion))
    XCTAssertTrue(t.criteriaApplies(artistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }
}
