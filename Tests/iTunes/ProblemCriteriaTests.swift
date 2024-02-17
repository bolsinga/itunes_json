//
//  ProblemCriteriaTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class ProblemCriteriaTests: XCTestCase {
  private var playDate: Date {
    // "2004-02-04T23:32:22Z"
    Date(timeIntervalSince1970: Double(1_075_937_542))
  }

  func testEmpty() throws {
    let p = Problem()
    let c = p.criteria

    XCTAssertTrue(c.isEmpty)
  }

  func testArtist() throws {
    let p = Problem(artist: "a")
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testAlbum() throws {
    let p = Problem(album: "a")
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(!c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testName() throws {
    let p = Problem(name: "a")
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testPlayCount() throws {
    let p = Problem(playCount: 3)
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testPlayDate() throws {
    let p = Problem(playDate: playDate)
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testPersistentID() throws {
    let p = Problem(persistentID: 123456)
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  func testAllSet() throws {
    let p = Problem(
      artist: "a", album: "l", name: "n", playCount: 3, playDate: playDate, persistentID: 123456)

    let c = p.criteria

    XCTAssertEqual(c.count, 6)
    XCTAssertTrue(!c.filter { $0.matchesAlbum("l") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesSong("n") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPlayCount(3) }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPlayDate(playDate) }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }
}
