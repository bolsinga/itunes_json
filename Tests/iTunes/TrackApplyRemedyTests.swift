//
//  TrackApplyRemedyTests.swift
//
//
//  Created by Greg Bolsinga on 2/10/24.
//

import Foundation
import Testing

@testable import iTunes

struct TrackApplyRemedyTests {
  @Test func ignore() {
    let t = Track(name: "s", persistentID: 0)
    let r = t.applyRemedy(.ignore)

    #expect(r == nil)
  }

  @Test func repairEmptyAlbum() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceAlbum("l")))
    let f = try #require(r.album)
    #expect(f == "l")
  }

  @Test func repairEmptyKind() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.repairEmptyKind("k")))
    let f = try #require(r.kind)
    #expect(f == "k")
  }

  @Test func replaceSortArtist() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceSortArtist("s")))
    let f = try #require(r.sortArtist)
    #expect(f == "s")
  }

  @Test func replaceTrackCount() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceTrackCount(3)))
    let f = try #require(r.trackCount)
    #expect(f == 3)
  }

  @Test func replaceTrackCount_alredySet() throws {
    let t = Track(name: "s", persistentID: 0, trackCount: 8)
    let r = try #require(t.applyRemedy(.replaceTrackCount(3)))
    let f = try #require(r.trackCount)
    #expect(f == 3)
  }

  @Test func repairEmptyTrackNumber() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.repairEmptyTrackNumber(3)))
    let f = try #require(r.trackNumber)
    #expect(f == 3)
  }

  @Test func repairEmptyYear() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.repairEmptyYear(1970)))
    let f = try #require(r.year)
    #expect(f == 1970)
  }

  @Test func replaceArtist() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceArtist("a")))
    let f = try #require(r.artist)
    #expect(f == "a")
  }

  @Test func replacePlayCount() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replacePlayCount(3)))
    let f = try #require(r.playCount)
    #expect(f == 3)
  }

  @Test func replacePlayDate() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(
      t.applyRemedy(.replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
    let f = try #require(r.playDateUTC)
    #expect(f == Date(timeIntervalSince1970: Double(1_075_937_542)))
  }

  @Test func replaceSong() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceSong("t")))
    let f = try #require(r.name)
    #expect(f == "t")
  }

  @Test func replaceDiscCount() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceDiscCount(3)))
    let f = try #require(r.discCount)
    #expect(f == 3)
  }

  @Test func replaceDiscNumber() throws {
    let t = Track(name: "s", persistentID: 0)
    let r = try #require(t.applyRemedy(.replaceDiscNumber(3)))
    let f = try #require(r.discNumber)
    #expect(f == 3)
  }
}
