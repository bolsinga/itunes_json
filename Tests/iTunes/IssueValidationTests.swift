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
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.isIgnored }.isEmpty)
  }

  func testIgnoreSong() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.isIgnored }.isEmpty)
  }

  func testIgnoreSongAndArtistInvalid() throws {
    let item = Item(problem: Problem(artist: "artist", name: "song"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testIgnoreAlbumInvalid() throws {
    let item = Item(problem: Problem(album: "album"), fix: Fix(ignore: true))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testRepairEmptySortArtist() throws {
    let item = Item(problem: Problem(artist: "The Artist"), fix: Fix(sortArtist: "Artist, The"))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("The Artist") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.sortArtist == "Artist, The" }.isEmpty)
  }

  func testRepairEmptySortArtistInvalid() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(sortArtist: "artist"))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testRepairEmptyKind() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.kind == "kind" }.isEmpty)
  }

  func testRepairEmptyKindMissingProperties() throws {
    let item = Item(
      problem: Problem(artist: "artist", name: "song"), fix: Fix(kind: "kind"))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testRepairEmptyYearArtistAlbum() throws {
    let item = Item(problem: Problem(artist: "artist", album: "album"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.year == 1970 }.isEmpty)
  }

  func testRepairEmptyYearArtistAlbumSong() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.year == 1970 }.isEmpty)
  }

  func testRepairEmptyYearAlbum() throws {
    let item = Item(problem: Problem(album: "album"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.year == 1970 }.isEmpty)
  }

  func testRepairEmptyYearArtist() throws {
    let item = Item(problem: Problem(artist: "artist"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testRepairEmptyYearSong() throws {
    let item = Item(problem: Problem(name: "song"), fix: Fix(year: 1970))
    let issue = item.issue

    XCTAssertNil(issue)
  }

  func testRepairEmptyTrackCountAlbum() throws {
    let item = Item(problem: Problem(album: "album"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 1)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 3 }.isEmpty)
  }

  func testRepairEmptyTrackCountAlbumArtist() throws {
    let item = Item(problem: Problem(artist: "artist", album: "album"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 3 }.isEmpty)
  }

  func testRepairEmptyTrackCountAlbumArtistSong() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 3 }.isEmpty)
  }

  func testRepairEmptyTrackCountArtistSong() throws {
    let item = Item(problem: Problem(artist: "artist", name: "song"), fix: Fix(trackCount: 3))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 1)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 3 }.isEmpty)
  }

  func testRepairEmptyAlbum() throws {
    let item = Item(
      problem: Problem(artist: "artist", name: "song"),
      fix: Fix(album: "song", trackCount: 1, trackNumber: 1))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 2)
    XCTAssertTrue(!remedies.filter { $0.album == "song" }.isEmpty)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 1 }.isEmpty)
  }

  func testRepairEmptyAlbumInvalid() throws {
    let item = Item(
      problem: Problem(artist: "artist", album: "album", name: "song"),
      fix: Fix(album: "song", trackCount: 1, trackNumber: 1))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 3)
    XCTAssertTrue(!critera.filter { $0.matchesAlbum("album") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 2)
    XCTAssertTrue(!remedies.filter { $0.album == "song" }.isEmpty)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 1 }.isEmpty)
  }

  func testReplaceArtist() throws {
    let item = Item(
      problem: Problem(artist: "artist", name: "song"),
      fix: Fix(artist: "Artist", trackCount: 1, trackNumber: 1))
    let issue = item.issue

    XCTAssertNotNil(issue)

    let critera = try XCTUnwrap(issue?.critera)
    XCTAssertEqual(critera.count, 2)
    XCTAssertTrue(!critera.filter { $0.matchesArtist("artist") }.isEmpty)
    XCTAssertTrue(!critera.filter { $0.matchesSong("song") }.isEmpty)

    let remedies = try XCTUnwrap(issue?.remedies)
    XCTAssertEqual(remedies.count, 2)
    XCTAssertTrue(!remedies.filter { $0.artist == "Artist" }.isEmpty)
    XCTAssertTrue(!remedies.filter { $0.trackCount == 1 }.isEmpty)
  }
}
