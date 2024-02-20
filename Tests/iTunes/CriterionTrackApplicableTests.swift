//
//  CriterionTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class CriterionTrackApplicableTests: XCTestCase {
  let h = CriterionVariantHelper(
    album: "l", artist: "a", song: "s", playCount: 3,
    playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), persistentID: 123456)

  func testSong() throws {
    let t = Track(name: h.song, persistentID: 0)

    XCTAssertFalse(t.criteriaApplies(h.albumCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumSong() throws {
    let t = Track(album: h.album, name: h.song, persistentID: 0)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistSong() throws {
    let t = Track(album: h.album, artist: h.artist, name: h.song, persistentID: 0)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistPlayCountPlayDateSong() throws {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: h.playDate)

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistPlayCountPlayDate_oneHourOff_Song() throws {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: Date(timeIntervalSince1970: h.playDate.timeIntervalSince1970 + 60 * 60))

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertTrue(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertTrue(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testAlbumArtistPlayCountPlayDate_oneHourOneSecondOff_Song() throws {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: Date(timeIntervalSince1970: h.playDate.timeIntervalSince1970 + (60 * 60) + 1))

    XCTAssertTrue(t.criteriaApplies(h.albumCriterion))
    XCTAssertTrue(t.criteriaApplies(h.artistCriterion))
    XCTAssertTrue(t.criteriaApplies(h.songCriterion))
    XCTAssertTrue(t.criteriaApplies(h.playCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.persistentIDCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.playCountPlayDateCriterion))
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
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    XCTAssertFalse(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    XCTAssertTrue(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    XCTAssertFalse(t.criteriaApplies(h.allCriterion))
    XCTAssertFalse(t.criteriaApplies([]))
  }

  func testPlayCountNil_matchesZero() throws {
    let t = Track(name: h.song, persistentID: 0)

    XCTAssertTrue(t.criteriaApplies([.playCount(0)]))
  }

  func testPersistentID() throws {
    let t = Track(name: h.song, persistentID: 123456)

    XCTAssertTrue(t.criteriaApplies(h.persistentIDCriterion))
  }

  func testEmptyAlbum() throws {
    let t = Track(name: "song", persistentID: 123456)

    XCTAssertFalse(t.criteriaApplies([.album("a")]))
    XCTAssertTrue(t.criteriaApplies([.album("")]))
  }

  func testNonMatchingAlbum() throws {
    let t = Track(album: "b", name: "song", persistentID: 123456)

    XCTAssertTrue(t.criteriaApplies([.album("b")]))
    XCTAssertFalse(t.criteriaApplies([.album("a")]))
    XCTAssertFalse(t.criteriaApplies([.album("")]))
  }
}
