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

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(critera[0].matchesArtist("artist"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].isIgnored)
  }

  func testIgnoreSong() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(critera[0].matchesSong("song"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].isIgnored)
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

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(critera[0].matchesArtist("The Artist"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].sortArtist == "Artist, The")
  }

  func testKind() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(critera[0].matchesAlbum("album"))
    XCTAssertTrue(critera[1].matchesArtist("artist"))
    XCTAssertTrue(critera[2].matchesSong("song"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].kind == "kind")
  }

  func testKindMissingProperties() throws {
    let item = Item(
      problem: Problem(artist: "artist", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testYearArtistAlbum() throws {
    let item = Item(problem: Problem(artist: "artist", album: "album"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(critera[0].matchesAlbum("album"))
    XCTAssertTrue(critera[1].matchesArtist("artist"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].year == 1970)
  }

  func testYearArtistAlbumSong() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(critera[0].matchesAlbum("album"))
    XCTAssertTrue(critera[1].matchesArtist("artist"))
    XCTAssertTrue(critera[2].matchesSong("song"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].year == 1970)
  }

  func testYearAlbum() throws {
    let item = Item(problem: Problem(album: "album"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(critera[0].matchesAlbum("album"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].year == 1970)
  }

  func testYearArtist() throws {
    let item = Item(problem: Problem(artist: "artist"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testYearSong() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testTrackCountAlbum() throws {
    let item = Item(problem: Problem(album: "album"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(critera[0].matchesAlbum("album"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].trackCount == 3)
  }

  func testTrackCountAlbumArtist() throws {
    let item = Item(problem: Problem(artist: "artist", album: "album"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(critera[0].matchesAlbum("album"))
    XCTAssertTrue(critera[1].matchesArtist("artist"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].trackCount == 3)
  }

  func testTrackCountAlbumArtistSong() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(critera[0].matchesAlbum("album"))
    XCTAssertTrue(critera[1].matchesArtist("artist"))
    XCTAssertTrue(critera[2].matchesSong("song"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].trackCount == 3)
  }

  func testTrackCountArtistSong() throws {
    let item = Item(problem: Problem(artist: "artist", name: "song"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(critera[0].matchesArtist("artist"))
    XCTAssertTrue(critera[1].matchesSong("song"))

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(remedies[0].trackCount == 3)
  }
}