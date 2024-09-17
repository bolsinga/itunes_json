//
//  RemedyTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import Foundation
import Testing

@testable import iTunes

struct RemedyTrackApplicableTests {
  @Test func ignore() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.ignore))
  }

  @Test func replaceAlbum() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceAlbum("l")))
    #expect(Track(album: "a", name: "s", persistentID: 0).remedyApplies(.replaceAlbum("l")))
  }

  @Test func repairEmptyKind() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyKind("k")))
    #expect(!Track(kind: "a", name: "s", persistentID: 0).remedyApplies(.repairEmptyKind("k")))
  }

  @Test func replaceSortArtist() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceSortArtist("s")))
    #expect(
      Track(artist: "a", name: "s", persistentID: 0, sortArtist: "a").remedyApplies(
        .replaceSortArtist("s")))
    #expect(
      Track(name: "s", persistentID: 0, sortArtist: "a").remedyApplies(.replaceSortArtist("s")))
  }

  @Test func replaceTrackCount() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceTrackCount(3)))
    #expect(Track(name: "s", persistentID: 0, trackCount: 0).remedyApplies(.replaceTrackCount(3)))
    #expect(Track(name: "s", persistentID: 0, trackCount: 2).remedyApplies(.replaceTrackCount(3)))
  }

  @Test func repairEmptyTrackNumber() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyTrackNumber(3)))
    #expect(
      Track(name: "s", persistentID: 0, trackNumber: 0).remedyApplies(.repairEmptyTrackNumber(3)))
    #expect(
      !Track(name: "s", persistentID: 0, trackNumber: 2).remedyApplies(.repairEmptyTrackNumber(3)))
  }

  @Test func repairEmptyYear() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.repairEmptyYear(1970)))
    #expect(!Track(name: "s", persistentID: 0, year: 1966).remedyApplies(.repairEmptyYear(1970)))
    #expect(Track(name: "s", persistentID: 0, year: 0).remedyApplies(.repairEmptyYear(1970)))
  }

  @Test func replaceArtist() {
    #expect(Track(artist: "b", name: "s", persistentID: 0).remedyApplies(.replaceArtist("a")))
    #expect(!Track(name: "s", persistentID: 0).remedyApplies(.replaceArtist("s")))
  }

  @Test func replacePlayCount() {
    #expect(Track(name: "s", persistentID: 0, playCount: 0).remedyApplies(.replacePlayCount(3)))
    #expect(Track(name: "s", persistentID: 0, playCount: 8).remedyApplies(.replacePlayCount(3)))
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replacePlayCount(3)))
  }

  @Test func replacePlayDate() {
    #expect(
      Track(name: "s", persistentID: 0, playDateUTC: Date.now).remedyApplies(
        .replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
    #expect(
      !Track(name: "s", persistentID: 0).remedyApplies(
        .replacePlayDate(Date(timeIntervalSince1970: Double(1_075_937_542)))))
  }

  @Test func replaceSong() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceSong("t")))
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceSong("s")))
  }

  @Test func replaceDiscCount() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
    #expect(Track(discCount: 0, name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
    #expect(Track(discCount: 1, name: "s", persistentID: 0).remedyApplies(.replaceDiscCount(3)))
  }

  @Test func replaceDiscNumber() {
    #expect(Track(name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
    #expect(Track(discNumber: 0, name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
    #expect(Track(discNumber: 1, name: "s", persistentID: 0).remedyApplies(.replaceDiscNumber(3)))
  }
}
