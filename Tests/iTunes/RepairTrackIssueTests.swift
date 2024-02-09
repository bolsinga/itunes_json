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

    let issue = Issue(criteria: [.song("song")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNil(fixedTrack)
  }

  func testRepairIgnoreArtist() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(criteria: [.artist("artist")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNil(fixedTrack)
  }

  func testRepairIgnoreInvalid() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(criteria: [.artist("artist"), .song("song")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(track, fixedTrack)
  }

  func testRepairIgnoreNotApplicable() throws {
    let track = Track(name: "song", persistentID: 0)

    let issue = Issue(criteria: [.song("cool")], remedies: [.ignore])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(track, fixedTrack)
  }

  func testRepairEmptySortArtist() throws {
    let track = Track(artist: "The Artist", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.artist("The Artist")], remedies: [.repairEmptySortArtist("Artist, The")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.sortArtist)
    XCTAssertEqual(fixedTrack?.sortArtist, "Artist, The")
  }

  func testRepairEmptySortArtistAlreadySet() throws {
    let track = Track(artist: "The Artist", name: "song", persistentID: 0, sortArtist: "Something")

    let issue = Issue(
      criteria: [.artist("The Artist")], remedies: [.repairEmptySortArtist("Artist, The")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairEmptyKind() throws {
    let track = Track(album: "album", artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.album("album"), .artist("artist"), .song("song")],
      remedies: [.repairEmptyKind("kind")]
    )

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.kind)
    XCTAssertEqual(fixedTrack?.kind, "kind")
  }

  func testRepairEmptyKindAlreadySet() throws {
    let track = Track(album: "album", artist: "artist", kind: "KIND", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.album("album"), .artist("artist"), .song("song")],
      remedies: [.repairEmptyKind("kind")]
    )

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairEmptyYear() throws {
    let track = Track(album: "album", name: "song", persistentID: 0)

    let issue = Issue(criteria: [.album("album")], remedies: [.repairEmptyYear(1970)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.year)
    XCTAssertEqual(fixedTrack?.year, 1970)
  }

  func testRepairEmptyYearAlreadySet() throws {
    let track = Track(album: "album", name: "song", persistentID: 0, year: 1971)

    let issue = Issue(criteria: [.album("album")], remedies: [.repairEmptyYear(1970)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairEmptyTrackCount() throws {
    let track = Track(album: "album", name: "song", persistentID: 0)

    let issue = Issue(criteria: [.album("album")], remedies: [.repairEmptyTrackCount(3)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.trackCount)
    XCTAssertEqual(fixedTrack?.trackCount, 3)
  }

  func testRepairEmptyTrackCountAlreadySet() throws {
    let track = Track(album: "album", name: "song", persistentID: 0, trackCount: 10)

    let issue = Issue(criteria: [.album("album")], remedies: [.repairEmptyTrackCount(3)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairEmptyAlbum() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.artist("artist"), .song("song")], remedies: [.repairEmptyAlbum("album")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.album)
    XCTAssertEqual(fixedTrack?.album, "album")
  }

  func testRepairEmptyAlbumAlreadySet() throws {
    let track = Track(album: "ALBUM", artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.artist("artist"), .song("song")], remedies: [.repairEmptyAlbum("album")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testReplaceArtist() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      criteria: [.artist("artist"), .song("song")], remedies: [.replaceArtist("Artist")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.artist)
    XCTAssertEqual(fixedTrack?.artist, "Artist")
  }

  func testReplaceArtistNotSet() throws {
    let track = Track(name: "song", persistentID: 0)

    let issue = Issue(criteria: [.song("song")], remedies: [.replaceArtist("artist")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }
}
