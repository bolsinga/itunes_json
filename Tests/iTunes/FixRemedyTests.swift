//
//  FixRemedyTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import Foundation
import Testing

@testable import iTunes

struct FixRemedyTests {
  @Test func empty() {
    let f = Fix()
    let r = f.remedies

    #expect(r.isEmpty)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func album() {
    let f = Fix(album: "a")
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.album == "a" }.count == 1)

    #expect(!r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func artist() {
    let f = Fix(artist: "a")
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.artist == "a" }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(!r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func kind() {
    let f = Fix(kind: "k")
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.kind == "k" }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(!r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func playCount() {
    let f = Fix(playCount: 3)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.playCount == 3 }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(!r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func playDate() {
    // "2004-02-04T23:32:22Z"
    let f = Fix(playDate: Date(timeIntervalSince1970: Double(1_075_937_542)))
    let r = f.remedies

    #expect(r.count == 1)

    #expect(
      r.filter { $0.playDate == Date(timeIntervalSince1970: Double(1_075_937_542)) }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(!r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func sortArtist() {
    let f = Fix(sortArtist: "a")
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.sortArtist == "a" }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(!r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func trackCount() {
    let f = Fix(trackCount: 3)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.trackCount == 3 }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(!r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func trackNumber() {
    let f = Fix(trackNumber: 3)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.trackNumber == 3 }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(!r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func year() {
    let f = Fix(year: 1970)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.year == 1970 }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(!r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func ignore_true() {
    let f = Fix(ignore: true)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.isIgnored }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(!r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func ignore_false() {
    let f = Fix(ignore: false)
    let r = f.remedies

    #expect(r.isEmpty)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func all_ignoreTrue() {
    let f = Fix(
      album: "l", artist: "a", kind: "k", playCount: 3,
      playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), sortArtist: "s", trackCount: 3,
      trackNumber: 4, year: 1970, ignore: true)
    let r = f.remedies

    #expect(r.count == 1)

    #expect(r.filter { $0.isIgnored }.count == 1)

    #expect(r.filter { $0.album != nil }.isEmpty)
    #expect(r.filter { $0.artist != nil }.isEmpty)
    #expect(!r.filter { $0.isIgnored }.isEmpty)
    #expect(r.filter { $0.kind != nil }.isEmpty)
    #expect(r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(r.filter { $0.trackCount != nil }.isEmpty)
    #expect(r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(r.filter { $0.year != nil }.isEmpty)
    #expect(r.filter { $0.playCount != nil }.isEmpty)
    #expect(r.filter { $0.playDate != nil }.isEmpty)
  }

  @Test func all_ignoreFalse() {
    let f = Fix(
      album: "l", artist: "a", kind: "k", playCount: 3,
      playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), sortArtist: "s", trackCount: 3,
      trackNumber: 2, year: 1970, ignore: false)
    let r = f.remedies

    #expect(r.count == 9)

    #expect(r.filter { $0.album == "l" }.count == 1)
    #expect(r.filter { $0.artist == "a" }.count == 1)
    #expect(r.filter { $0.kind == "k" }.count == 1)
    #expect(r.filter { $0.sortArtist == "s" }.count == 1)
    #expect(r.filter { $0.trackCount == 3 }.count == 1)
    #expect(r.filter { $0.trackNumber == 2 }.count == 1)
    #expect(r.filter { $0.year == 1970 }.count == 1)
    #expect(r.filter { $0.playCount == 3 }.count == 1)
    #expect(
      r.filter { $0.playDate == Date(timeIntervalSince1970: Double(1_075_937_542)) }.count == 1)

    #expect(!r.filter { $0.album != nil }.isEmpty)
    #expect(!r.filter { $0.artist != nil }.isEmpty)
    #expect(r.filter { $0.isIgnored }.isEmpty)
    #expect(!r.filter { $0.kind != nil }.isEmpty)
    #expect(!r.filter { $0.sortArtist != nil }.isEmpty)
    #expect(!r.filter { $0.trackCount != nil }.isEmpty)
    #expect(!r.filter { $0.trackNumber != nil }.isEmpty)
    #expect(!r.filter { $0.year != nil }.isEmpty)
    #expect(!r.filter { $0.playCount != nil }.isEmpty)
    #expect(!r.filter { $0.playDate != nil }.isEmpty)
  }
}
