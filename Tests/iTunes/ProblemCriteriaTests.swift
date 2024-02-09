//
//  ProblemCriteriaTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import XCTest

@testable import iTunes

final class ProblemCriteriaTests: XCTestCase {
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
  }

  func testAlbum() throws {
    let p = Problem(album: "a")
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(!c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesSong("a") }.isEmpty)
  }

  func testName() throws {
    let p = Problem(name: "a")
    let c = p.criteria

    XCTAssertEqual(c.count, 1)
    XCTAssertTrue(c.filter { $0.matchesAlbum("a") }.isEmpty)
    XCTAssertTrue(c.filter { $0.matchesArtist("a") }.isEmpty)
    XCTAssertTrue(!c.filter { $0.matchesSong("a") }.isEmpty)
  }

  func testPlayCount() throws {
    let p = Problem(playCount: 3)
    let c = p.criteria

    XCTAssertTrue(c.isEmpty)
  }

  func testPlayDate() throws {
    // "2004-02-04T23:32:22Z"
    let p = Problem(playDate: Date(timeIntervalSince1970: Double(1_075_937_542)))
    let c = p.criteria

    XCTAssertTrue(c.isEmpty)
  }
}
