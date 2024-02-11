//
//  RemedyCriteriaValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class RemedyCriteriaValidationTests: XCTestCase {
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

  func testIgnore() throws {
    let r = Remedy.ignore

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertTrue(r.validate([Criterion.artist("z")]))
    XCTAssertTrue(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertFalse(r.validate(albumArtistCriterion))
    XCTAssertFalse(r.validate(albumSongCriterion))
    XCTAssertFalse(r.validate(artistSongCriterion))
    XCTAssertFalse(r.validate(albumArtistSongCriterion))
    XCTAssertFalse(r.validate(albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertFalse(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertFalse(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyAlbum() throws {
    let r = Remedy.repairEmptyAlbum("a")

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertTrue(r.validate([Criterion.artist("z")]))
    XCTAssertTrue(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertTrue(r.validate(albumArtistCriterion))
    XCTAssertTrue(r.validate(albumSongCriterion))
    XCTAssertTrue(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertTrue(r.validate(artistPlayCountCriterion))
    XCTAssertTrue(r.validate(songPlayCountCriterion))
    XCTAssertTrue(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyKind() throws {
    let r = Remedy.repairEmptyKind("k")

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertFalse(r.validate([Criterion.artist("z")]))
    XCTAssertFalse(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertFalse(r.validate(albumArtistCriterion))
    XCTAssertFalse(r.validate(albumSongCriterion))
    XCTAssertFalse(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertFalse(r.validate(albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertFalse(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertFalse(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptySortArtist() throws {
    let r = Remedy.repairEmptySortArtist("a")

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertTrue(r.validate([Criterion.artist("z")]))
    XCTAssertFalse(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertFalse(r.validate(albumArtistCriterion))
    XCTAssertFalse(r.validate(albumSongCriterion))
    XCTAssertFalse(r.validate(artistSongCriterion))
    XCTAssertFalse(r.validate(albumArtistSongCriterion))
    XCTAssertFalse(r.validate(albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(albumSongPlayCountCriterion))
    XCTAssertFalse(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertFalse(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertFalse(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackCount() throws {
    let r = Remedy.repairEmptyTrackCount(3)

    XCTAssertTrue(r.validate([Criterion.album("z")]))
    XCTAssertTrue(r.validate([Criterion.artist("z")]))
    XCTAssertFalse(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertTrue(r.validate(albumArtistCriterion))
    XCTAssertTrue(r.validate(albumSongCriterion))
    XCTAssertTrue(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(artistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(albumPlayCountCriterion))
    XCTAssertTrue(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertTrue(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyTrackNumber() throws {
    let r = Remedy.repairEmptyTrackNumber(3)

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertFalse(r.validate([Criterion.artist("z")]))
    XCTAssertFalse(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertTrue(r.validate(albumArtistCriterion))
    XCTAssertFalse(r.validate(albumSongCriterion))
    XCTAssertTrue(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistPlayCountCriterion))
    XCTAssertFalse(r.validate(albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertFalse(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertTrue(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testRepairEmptyYear() throws {
    let r = Remedy.repairEmptyYear(1970)

    XCTAssertTrue(r.validate([Criterion.album("z")]))
    XCTAssertFalse(r.validate([Criterion.artist("z")]))
    XCTAssertFalse(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertTrue(r.validate(albumArtistCriterion))
    XCTAssertTrue(r.validate(albumSongCriterion))
    XCTAssertTrue(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(artistSongPlayCountCriterion))
    XCTAssertTrue(r.validate(albumPlayCountCriterion))
    XCTAssertFalse(r.validate(artistPlayCountCriterion))
    XCTAssertFalse(r.validate(songPlayCountCriterion))
    XCTAssertTrue(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }

  func testReplaceArtist() throws {
    let r = Remedy.replaceArtist("a")

    XCTAssertFalse(r.validate([Criterion.album("z")]))
    XCTAssertTrue(r.validate([Criterion.artist("z")]))
    XCTAssertTrue(r.validate([Criterion.song("z")]))
    XCTAssertFalse(r.validate([Criterion.playCount(3)]))
    XCTAssertTrue(r.validate(albumArtistCriterion))
    XCTAssertTrue(r.validate(albumSongCriterion))
    XCTAssertTrue(r.validate(artistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistSongCriterion))
    XCTAssertTrue(r.validate(albumArtistPlayCountCriterion))
    XCTAssertTrue(r.validate(albumSongPlayCountCriterion))
    XCTAssertTrue(r.validate(artistSongPlayCountCriterion))
    XCTAssertFalse(r.validate(albumPlayCountCriterion))
    XCTAssertTrue(r.validate(artistPlayCountCriterion))
    XCTAssertTrue(r.validate(songPlayCountCriterion))
    XCTAssertTrue(r.validate(allCriterion))
    XCTAssertFalse(r.validate([]))
  }
}
