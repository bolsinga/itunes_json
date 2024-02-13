//
//  TrackApplyRemedyTests.swift
//
//
//  Created by Greg Bolsinga on 2/10/24.
//

import XCTest

@testable import iTunes

final class TrackApplyRemedyTests: XCTestCase {
  func testIgnore() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = t.applyRemedy(.ignore)

    XCTAssertNil(r)
  }

  func testRepairEmptyAlbum() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptyAlbum("l")))
    let f = try XCTUnwrap(r.album)
    XCTAssertEqual(f, "l")
  }

  func testRepairEmptyKind() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptyKind("k")))
    let f = try XCTUnwrap(r.kind)
    XCTAssertEqual(f, "k")
  }

  func testRepairEmptySortArtist() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptySortArtist("s")))
    let f = try XCTUnwrap(r.sortArtist)
    XCTAssertEqual(f, "s")
  }

  func testRepairEmptyTrackCount() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptyTrackCount(3)))
    let f = try XCTUnwrap(r.trackCount)
    XCTAssertEqual(f, 3)
  }

  func testRepairEmptyTrackNumber() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptyTrackNumber(3)))
    let f = try XCTUnwrap(r.trackNumber)
    XCTAssertEqual(f, 3)
  }

  func testRepairEmptyYear() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.repairEmptyYear(1970)))
    let f = try XCTUnwrap(r.year)
    XCTAssertEqual(f, 1970)
  }

  func testReplaceArtist() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.replaceArtist("a")))
    let f = try XCTUnwrap(r.artist)
    XCTAssertEqual(f, "a")
  }

  func testReplacePlayCount() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(t.applyRemedy(.replacePlayCount(3)))
    let f = try XCTUnwrap(r.playCount)
    XCTAssertEqual(f, 3)
  }

  func testReplacePlayDate() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try XCTUnwrap(
      t.applyRemedy(.replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
    let f = try XCTUnwrap(r.playDateUTC)
    XCTAssertEqual(f, Date(timeIntervalSince1970: Double(1_075_937_542)))
  }
}
