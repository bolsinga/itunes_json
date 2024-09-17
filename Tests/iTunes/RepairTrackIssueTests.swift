//
//  RepairTrackIssueTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import Testing

@testable import iTunes

struct RepairTrackIssueTests {
  @Test func issueCriteriaDoesNotApply() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try #require(
      Issue.create(
        criteria: [.album("l"), .artist("a"), .song("nomatch")], remedies: [.repairEmptyKind("k")]))

    let f = t.repair(i)

    #expect(f == t)
  }

  @Test func issueCriteriaAppliesNoRemedies() throws {
    let t = Track(album: "l", artist: "a", kind: "k", name: "s", persistentID: 0)

    let i = try #require(
      Issue.create(
        criteria: [.album("l"), .artist("a"), .song("s")], remedies: [.repairEmptyKind("k")]))

    let f = t.repair(i)

    #expect(f == t)
  }

  @Test func issueCriteriaAppliesIgnoreOnly() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try #require(Issue.create(criteria: [.artist("a")], remedies: [.ignore]))

    let f = t.repair(i)

    #expect(f == nil)
  }

  @Test func issueCriteriaAppliesIgnoreAndMore() throws {
    let t = Track(album: "l", artist: "a", name: "s", persistentID: 0)

    let i = try #require(
      Issue.create(criteria: [.artist("a")], remedies: [.ignore, .replaceSortArtist("sa")]))

    let f = t.repair(i)

    #expect(f == nil)
  }
}
