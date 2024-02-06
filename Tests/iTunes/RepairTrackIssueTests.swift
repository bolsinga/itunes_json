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

  func testRepairKind() throws {
    let track = Track(album: "album", artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.album("album"), .artist("artist"), .song("song")], remedies: [.correctKind("kind")]
    )

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.kind)
    XCTAssertEqual(fixedTrack?.kind, "kind")
  }

  func testRepairKindAlreadySet() throws {
    let track = Track(album: "album", artist: "artist", kind: "KIND", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.album("album"), .artist("artist"), .song("song")], remedies: [.correctKind("kind")]
    )

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairYear() throws {
    let track = Track(album: "album", name: "song", persistentID: 0)

    let issue = Issue(critera: [.album("album")], remedies: [.correctYear(1970)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.year)
    XCTAssertEqual(fixedTrack?.year, 1970)
  }

  func testRepairYearAlreadySet() throws {
    let track = Track(album: "album", name: "song", persistentID: 0, year: 1971)

    let issue = Issue(critera: [.album("album")], remedies: [.correctYear(1970)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairTrackCount() throws {
    let track = Track(album: "album", name: "song", persistentID: 0)

    let issue = Issue(critera: [.album("album")], remedies: [.correctTrackCount(3)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.trackCount)
    XCTAssertEqual(fixedTrack?.trackCount, 3)
  }

  func testRepairTrackCountAlreadySet() throws {
    let track = Track(album: "album", name: "song", persistentID: 0, trackCount: 10)

    let issue = Issue(critera: [.album("album")], remedies: [.correctTrackCount(3)])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairAlbum() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.artist("artist"), .song("song")], remedies: [.correctAlbum("album")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.album)
    XCTAssertEqual(fixedTrack?.album, "album")
  }

  func testRepairAlbumAlreadySet() throws {
    let track = Track(album: "ALBUM", artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.artist("artist"), .song("song")], remedies: [.correctAlbum("album")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }

  func testRepairArtist() throws {
    let track = Track(artist: "artist", name: "song", persistentID: 0)

    let issue = Issue(
      critera: [.artist("artist"), .song("song")], remedies: [.correctArtist("Artist")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertNotNil(fixedTrack?.artist)
    XCTAssertEqual(fixedTrack?.artist, "Artist")
  }

  func testRepairArtistNotSet() throws {
    let track = Track(name: "song", persistentID: 0)

    let issue = Issue(critera: [.song("song")], remedies: [.correctArtist("artist")])

    let fixedTrack = track.repair(issue)

    XCTAssertNotNil(fixedTrack)
    XCTAssertEqual(fixedTrack, track)
  }
}
