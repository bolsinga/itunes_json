//
//  CriterionTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class CriterionTrackApplicableTests: XCTestCase {
  let h = CriterionVariantHelper(album: "l", artist: "a", song: "s", playCount: 3)

  func testSong() throws {
    let t = Track(name: h.song, persistentID: 0)

    XCTAssertFalse(t.criteriaApplies(h.albumCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumSong() throws {
    let t = Track(album: h.album, name: h.song, persistentID: 0)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistSong() throws {
    let t = Track(album: h.album, artist: h.artist, name: h.song, persistentID: 0)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistPlayCountSong() throws {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }
}
