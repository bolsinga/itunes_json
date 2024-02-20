//
//  RemedyCriteriaValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class RemedyCriteriaValidationTests: XCTestCase {
  let h = CriterionVariantHelper(
    album: "l", artist: "a", song: "s", playCount: 3,
    playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), persistentID: 123456)

  func testIgnore() throws {
    let r = Remedy.ignore

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertTrue(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplaceAlbum() throws {
    let r = Remedy.replaceAlbum("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyKind() throws {
    let r = Remedy.repairEmptyKind("k")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplaceSortArtist() throws {
    let r = Remedy.replaceSortArtist("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackCount() throws {
    let r = Remedy.repairEmptyTrackCount(3)

    XCTAssertTrue(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertTrue(r.validate(h.albumPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackNumber() throws {
    let r = Remedy.repairEmptyTrackNumber(3)

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyYear() throws {
    let r = Remedy.repairEmptyYear(1970)

    XCTAssertTrue(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertTrue(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplaceArtist() throws {
    let r = Remedy.replaceArtist("a")

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertTrue(r.validate(h.artistCriterion))
    XCTAssertTrue(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplacePlayCount() throws {
    let r = Remedy.replacePlayCount(3)

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplacePlayDate() throws {
    let r = Remedy.replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))

    XCTAssertFalse(r.validate(h.albumCriterion))
    XCTAssertFalse(r.validate(h.artistCriterion))
    XCTAssertFalse(r.validate(h.songCriterion))
    XCTAssertFalse(r.validate(h.playCountCriterion))
    XCTAssertFalse(r.validate(h.playDateCriterion))
    XCTAssertFalse(r.validate(h.persistentIDCriterion))
    XCTAssertFalse(r.validate(h.albumPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayDateCriterion))
    XCTAssertFalse(r.validate(h.playCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistCriterion))
    XCTAssertFalse(r.validate(h.albumSongCriterion))
    XCTAssertFalse(r.validate(h.artistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(r.validate(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(r.validate(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(h.allCriterion))
    XCTAssertFalse(r.validate([]))
  }
}
