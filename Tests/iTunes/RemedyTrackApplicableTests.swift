//
//  RemedyTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class RemedyTrackApplicableTests: XCTestCase {
  func testIgnore() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.ignore))
  }

  func testReplaceAlbum() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceAlbum("l")))
    XCTAssertTrue(
      Track(album: "a", name: "s", persistentID: 0).remedyApplies(.replaceAlbum("l")))
  }

  func testRepairEmptyKind() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyKind("k")))
    XCTAssertFalse(
      Track(kind: "a", name: "s", persistentID: 0).remedyApplies(.repairEmptyKind("k")))
  }

  func testReplaceSortArtist() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceSortArtist("s")))
    XCTAssertTrue(
      Track(artist: "a", name: "s", persistentID: 0, sortArtist: "a").remedyApplies(
        .replaceSortArtist("s")))
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, sortArtist: "a").remedyApplies(.replaceSortArtist("s")))
  }

  func testReplaceTrackCount() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceTrackCount(3)))
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, trackCount: 0).remedyApplies(.replaceTrackCount(3)))
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, trackCount: 2).remedyApplies(.replaceTrackCount(3)))
  }

  func testRepairEmptyTrackNumber() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyTrackNumber(3)))
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, trackNumber: 0).remedyApplies(.repairEmptyTrackNumber(3)))
    XCTAssertFalse(
      Track(name: "s", persistentID: 0, trackNumber: 2).remedyApplies(.repairEmptyTrackNumber(3)))
  }

  func testRepairEmptyYear() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyYear(1970)))
    XCTAssertFalse(
      Track(name: "s", persistentID: 0, year: 1966).remedyApplies(.repairEmptyYear(1970)))
    XCTAssertTrue(Track(name: "s", persistentID: 0, year: 0).remedyApplies(.repairEmptyYear(1970)))
  }

  func testReplaceArtist() throws {
    XCTAssertTrue(Track(artist: "b", name: "s", persistentID: 0).remedyApplies(.replaceArtist("a")))
    XCTAssertFalse(Track(name: "s", persistentID: 0).remedyApplies(.replaceArtist("s")))
  }

  func testReplacePlayCount() throws {
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, playCount: 0).remedyApplies(.replacePlayCount(3)))
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, playCount: 8).remedyApplies(.replacePlayCount(3)))
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replacePlayCount(3)))
  }

  func testReplacePlayDate() throws {
    XCTAssertTrue(
      Track(name: "s", persistentID: 0, playDateUTC: Date.now).remedyApplies(
        .replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
    XCTAssertFalse(
      Track(name: "s", persistentID: 0).remedyApplies(
        .replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
  }

  func testReplaceSong() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceSong("t")))
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceSong("s")))
  }

  func testReplaceDiscCount() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
    XCTAssertTrue(
      Track(discCount: 0, name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
    XCTAssertTrue(
      Track(discCount: 1, name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
  }

  func testReplaceDiscNumber() throws {
    XCTAssertTrue(Track(name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
    XCTAssertTrue(
      Track(discNumber: 0, name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
    XCTAssertTrue(
      Track(discNumber: 1, name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
  }
}
