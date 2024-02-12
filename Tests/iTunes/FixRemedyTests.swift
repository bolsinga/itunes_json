//
//  FixRemedyTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class FixRemedyTests: XCTestCase {
  func testEmpty() throws {
    let f = Fix()
    let r = f.remedies

    XCTAssertTrue(r.isEmpty)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testAlbum() throws {
    let f = Fix(album: "a")
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.album == "a" }.count, 1)

    XCTAssertFalse(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testArtist() throws {
    let f = Fix(artist: "a")
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.artist == "a" }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testKind() throws {
    let f = Fix(kind: "k")
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.kind == "k" }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertFalse(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testPlayCount() throws {
    let f = Fix(playCount: 3)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.playCount == 3 }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testPlayDate() throws {
    // "2004-02-04T23:32:22Z"
    let f = Fix(playDate: Date(timeIntervalSince1970: Double(1_075_937_542)))
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(
      r.filter { $0.playDate == Date(timeIntervalSince1970: Double(1_075_937_542)) }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testSortArtist() throws {
    let f = Fix(sortArtist: "a")
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.sortArtist == "a" }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testTrackCount() throws {
    let f = Fix(trackCount: 3)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.trackCount == 3 }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testTrackNumber() throws {
    let f = Fix(trackNumber: 3)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.trackNumber == 3 }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testYear() throws {
    let f = Fix(year: 1970)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.year == 1970 }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testIgnore_true() throws {
    let f = Fix(ignore: true)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.isIgnored }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testIgnore_false() throws {
    let f = Fix(ignore: false)
    let r = f.remedies

    XCTAssertTrue(r.isEmpty)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testAll_ignoreTrue() throws {
    let f = Fix(
      album: "l", artist: "a", kind: "k", playCount: 3,
      playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), sortArtist: "s", trackCount: 3,
      trackNumber: 4, year: 1970, ignore: true)
    let r = f.remedies

    XCTAssertEqual(r.count, 1)

    XCTAssertEqual(r.filter { $0.isIgnored }.count, 1)

    XCTAssertTrue(r.filter { $0.album != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertTrue(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.year != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.playDate != nil }.isEmpty)
  }

  func testAll_ignoreFalse() throws {
    let f = Fix(
      album: "l", artist: "a", kind: "k", playCount: 3,
      playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), sortArtist: "s", trackCount: 3,
      trackNumber: 2, year: 1970, ignore: false)
    let r = f.remedies

    XCTAssertEqual(r.count, 9)

    XCTAssertEqual(r.filter { $0.album == "l" }.count, 1)
    XCTAssertEqual(r.filter { $0.artist == "a" }.count, 1)
    XCTAssertEqual(r.filter { $0.kind == "k" }.count, 1)
    XCTAssertEqual(r.filter { $0.sortArtist == "s" }.count, 1)
    XCTAssertEqual(r.filter { $0.trackCount == 3 }.count, 1)
    XCTAssertEqual(r.filter { $0.trackNumber == 2 }.count, 1)
    XCTAssertEqual(r.filter { $0.year == 1970 }.count, 1)
    XCTAssertEqual(r.filter { $0.playCount == 3 }.count, 1)
    XCTAssertEqual(
      r.filter { $0.playDate == Date(timeIntervalSince1970: Double(1_075_937_542)) }.count, 1)

    XCTAssertFalse(r.filter { $0.album != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.artist != nil }.isEmpty)
    XCTAssertTrue(r.filter { $0.isIgnored }.isEmpty)
    XCTAssertFalse(r.filter { $0.kind != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.sortArtist != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.trackCount != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.trackNumber != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.year != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.playCount != nil }.isEmpty)
    XCTAssertFalse(r.filter { $0.playDate != nil }.isEmpty)
  }
}
