//
//  RepairTrackIssueTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import XCTest

@testable import iTunes

final class RepairTrackIssueTests: XCTestCase {
  func testIssueCriteriaDoesNotApply() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try XCTUnwrap(
      Issue.create(
        criteria: [.album("l"), .artist("a"), .song("nomatch")], remedies: [.repairEmptyKind("k")]))

    let f = t.repair(i)

    XCTAssertEqual(f, t)
  }

  func testIssueCriteriaAppliesNoRemedies() throws {
    let t = Track(album: "l", artist: "a", kind: "k", name: "s", persistentID: 0)

    let i = try XCTUnwrap(
      Issue.create(
        criteria: [.album("l"), .artist("a"), .song("s")], remedies: [.repairEmptyKind("k")]))

    let f = t.repair(i)

    XCTAssertEqual(f, t)
  }

  func testIssueCriteriaAppliesIgnoreOnly() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try XCTUnwrap(Issue.create(criteria: [.artist("a")], remedies: [.ignore]))

    let f = t.repair(i)

    XCTAssertNil(f)
  }

  func testIssueCriteriaAppliesIgnoreAndMore() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try XCTUnwrap(
      Issue.create(criteria: [.artist("a")], remedies: [.ignore, .replaceSortArtist("sa")]))

    let f = t.repair(i)

    XCTAssertNil(f)
  }
}
