//
//  ProblemCriteriaTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import Foundation
import Testing

@testable import iTunes

struct ProblemCriteriaTests {
  private var mockPlayDate: Date {
    // "2004-02-04T23:32:22Z"
    Date(timeIntervalSince1970: Double(1_075_937_542))
  }

  @Test func empty() {
    let p = Problem()
    let c = p.criteria

    #expect(c.isEmpty)
  }

  @Test func artist() {
    let p = Problem(artist: "a")
    let c = p.criteria

    #expect(c.count == 1)
    #expect(c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(!c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func album() {
    let p = Problem(album: "a")
    let c = p.criteria

    #expect(c.count == 1)
    #expect(!c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func name() {
    let p = Problem(name: "a")
    let c = p.criteria

    #expect(c.count == 1)
    #expect(c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(!c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func playCount() {
    let p = Problem(playCount: 3)
    let c = p.criteria

    #expect(c.count == 1)
    #expect(c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(!c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func playDate() {
    let p = Problem(playDate: mockPlayDate)
    let c = p.criteria

    #expect(c.count == 1)
    #expect(c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(!c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func persistentID() {
    let p = Problem(persistentID: 123456)
    let c = p.criteria

    #expect(c.count == 1)
    #expect(c.filter { $0.matchesAlbum("a") }.isEmpty)
    #expect(c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(c.filter { $0.matchesSong("a") }.isEmpty)
    #expect(c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(!c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }

  @Test func allSet() {
    let p = Problem(
      artist: "a", album: "l", name: "n", playCount: 3, playDate: mockPlayDate, persistentID: 123456
    )

    let c = p.criteria

    #expect(c.count == 6)
    #expect(!c.filter { $0.matchesAlbum("l") }.isEmpty)
    #expect(!c.filter { $0.matchesArtist("a") }.isEmpty)
    #expect(!c.filter { $0.matchesSong("n") }.isEmpty)
    #expect(!c.filter { $0.matchesPlayCount(3) }.isEmpty)
    #expect(!c.filter { $0.matchesPlayDate(mockPlayDate) }.isEmpty)
    #expect(!c.filter { $0.matchesPersistentId(123456) }.isEmpty)
  }
}
