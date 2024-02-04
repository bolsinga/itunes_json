//
//  RepairTrackIssueTests.swift
//
//
//  Created by Greg Bolsinga on 2/4/24.
//

import XCTest

@testable import iTunes

final class RepairTrackIssueTests: XCTestCase {
  func testRepairIgnoreSong() throws {
    let track = Track(name: "song", persistentID: 0)

    let issue = Issue(critera: [.song("song")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNil(fixedTrack)
  }

  func testRepairIgnoreArtist() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(critera: [.artist("artist")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNil(fixedTrack)
  }

  func testRepairIgnoreInvalid() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(critera: [.artist("artist"), .song("song")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(track, fixedTrack)
  }

  func testRepairIgnoreNotApplicable() throws {
    let track = Track(name: "song", persistentID: 0)

    let issue = Issue(critera: [.song("cool")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(track, fixedTrack)
  }

  func testRepairSortArtist() throws {
    let track = Track(artist: "The Artist", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.artist("The Artist")], remedies: [.correctSortArtist("Artist, The")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.sortArtist)
    XCTAssertEqual(fixedTrack?.sortArtist, "Artist, The")
  }

  func testRepairSortArtistAlreadySet() throws {
    let track = Track(artist: "The Artist", name: "song", persistentID: 0, sortArtist: "Something")

    let issue = Issue(
      critera: [.artist("The Artist")], remedies: [.correctSortArtist("Artist, The")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }
}
