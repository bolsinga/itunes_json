//
//  IssueValidationTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import XCTest

@testable import iTunes

final class IssueValidationTests: XCTestCase {
  func testNoRemedies() throws {
    let item = Item(problem: Problem(artist: "artist"), fix: Fix())
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testNoCriteria() throws {
    let item = Item(problem: Problem(), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testIgnoreFalseInvalid() throws {
    let item = Item(problem: Problem(artist: "artist"), fix: Fix(ignore: false))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testIgnoreArtist() throws {
    let item = Item(problem: Problem(artist: "artist"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNotNil(issue)
    XCTAssertEqual(issue?.critera.count, 1)
    XCTAssertTrue((issue?.critera[0])!.matchesArtist("artist"))

    XCTAssertEqual(issue?.remedies.count, 1)
    XCTAssertTrue((issue?.remedies[0])!.isIgnored)
  }

  func testIgnoreSong() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNotNil(issue)
    XCTAssertEqual(issue?.critera.count, 1)
    XCTAssertTrue((issue?.critera[0])!.matchesSong("song"))

    XCTAssertEqual(issue?.remedies.count, 1)
    XCTAssertTrue((issue?.remedies[0])!.isIgnored)
  }

  func testIgnoreSongAndArtistInvalid() throws {
    let item = Item(problem: Problem(artist: "artist", name: "song"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testSortArtist() throws {
    let item = Item(problem: Problem(artist: "The Artist"), fix: Fix(sortArtist: "Artist, The"))
    let issue = item.issue

    XCTAssertNotNil(issue)
    XCTAssertEqual(issue?.critera.count, 1)
    XCTAssertTrue((issue?.critera[0])!.matchesArtist("The Artist"))

    XCTAssertEqual(issue?.remedies.count, 1)
    XCTAssertTrue((issue?.remedies[0])!.sortArtist == "Artist, The")
  }

  func testKind() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNotNil(issue)
    XCTAssertEqual(issue?.critera.count, 3)
    XCTAssertTrue((issue?.critera[0])!.matchesAlbum("album"))
    XCTAssertTrue((issue?.critera[1])!.matchesArtist("artist"))
    XCTAssertTrue((issue?.critera[2])!.matchesSong("song"))

    XCTAssertEqual(issue?.remedies.count, 1)
    XCTAssertTrue((issue?.remedies[0])!.kind == "kind")
  }

  func testKindMissingProperties() throws {
    let item = Item(
      problem: Problem(artist: "artist", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNil(issue)
  }
}
