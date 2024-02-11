//
//  RemedyCriteriaValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class RemedyCriteriaValidationTests: XCTestCase {
  let h = CriterionVariantHelper(album: "l", artist: "a", song: "s", playCount: 3)

  func testIgnore() throws {
    let r = Remedy.ignore

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.albumArtistCriterion))
    XCTAssertFalse(r.validate(h.albumSongCriterion))
    XCTAssertFalse(r.validate(h.artistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyAlbum() throws {
    let r = Remedy.repairEmptyAlbum("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertTrue(r.validate(h.albumArtistCriterion))
    XCTAssertTrue(r.validate(h.albumSongCriterion))
    XCTAssertTrue(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.songPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyKind() throws {
    let r = Remedy.repairEmptyKind("k")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.albumArtistCriterion))
    XCTAssertFalse(r.validate(h.albumSongCriterion))
    XCTAssertFalse(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptySortArtist() throws {
    let r = Remedy.repairEmptySortArtist("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.albumArtistCriterion))
    XCTAssertFalse(r.validate(h.albumSongCriterion))
    XCTAssertFalse(r.validate(h.artistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackCount() throws {
    let r = Remedy.repairEmptyTrackCount(3)

    XCTAssertTrue(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertTrue(r.validate(h.albumArtistCriterion))
    XCTAssertTrue(r.validate(h.albumSongCriterion))
    XCTAssertTrue(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackNumber() throws {
    let r = Remedy.repairEmptyTrackNumber(3)

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertTrue(r.validate(h.albumArtistCriterion))
    XCTAssertFalse(r.validate(h.albumSongCriterion))
    XCTAssertTrue(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyYear() throws {
    let r = Remedy.repairEmptyYear(1970)

    XCTAssertTrue(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertTrue(r.validate(h.albumArtistCriterion))
    XCTAssertTrue(r.validate(h.albumSongCriterion))
    XCTAssertTrue(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplaceArtist() throws {
    let r = Remedy.replaceArtist("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertTrue(r.validate(h.albumArtistCriterion))
    XCTAssertTrue(r.validate(h.albumSongCriterion))
    XCTAssertTrue(r.validate(h.artistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountCriterion))
    XCTAssertTrue(r.validate(h.songPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }
}
