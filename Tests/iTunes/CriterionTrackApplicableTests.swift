//
//  CriterionTrackApplicableTests.swift
//
//
//  Created by Greg Bolsinga on 2/9/24.
//

import Foundation
import Testing

@testable import iTunes

struct CriterionTrackApplicableTests {
  let h = CriterionVariantHelper(
    album: "l", artist: "a", song: "s", playCount: 3,
    playDate: Date(timeIntervalSince1970: Double(1_075_937_542)), persistentID: 123456)

  @Test func song() {
    let t = Track(name: h.song, persistentID: 0)

    #expect(!t.criteriaApplies(h.albumCriterion))
    #expect(!t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(!t.criteriaApplies(h.playCountCriterion))
    #expect(!t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(!t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayDateCriterion))
    #expect(!t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistCriterion))
    #expect(!t.criteriaApplies(h.albumSongCriterion))
    #expect(!t.criteriaApplies(h.artistSongCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumSong() {
    let t = Track(album: h.album, name: h.song, persistentID: 0)

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(!t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(!t.criteriaApplies(h.playCountCriterion))
    #expect(!t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(!t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayDateCriterion))
    #expect(!t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(!t.criteriaApplies(h.artistSongCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumArtistSong() {
    let t = Track(album: h.album, artist: h.artist, name: h.song, persistentID: 0)

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(!t.criteriaApplies(h.playCountCriterion))
    #expect(!t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(!t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayDateCriterion))
    #expect(!t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(t.criteriaApplies(h.artistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumArtistPlayCountSong() {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount)

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(t.criteriaApplies(h.playCountCriterion))
    #expect(!t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(!t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayDateCriterion))
    #expect(!t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(t.criteriaApplies(h.artistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(t.criteriaApplies(h.songPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumArtistPlayCountPlayDateSong() {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: h.playDate)

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(t.criteriaApplies(h.playCountCriterion))
    #expect(t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(t.criteriaApplies(h.songPlayDateCriterion))
    #expect(t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(t.criteriaApplies(h.artistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(t.criteriaApplies(h.songPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumArtistPlayCountPlayDate_oneHourOff_Song() {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: Date(timeIntervalSince1970: h.playDate.timeIntervalSince1970 + 60 * 60))

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(t.criteriaApplies(h.playCountCriterion))
    #expect(t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(t.criteriaApplies(h.songPlayDateCriterion))
    #expect(t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(t.criteriaApplies(h.artistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(t.criteriaApplies(h.songPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func albumArtistPlayCountPlayDate_oneHourOneSecondOff_Song() {
    let t = Track(
      album: h.album, artist: h.artist, name: h.song, persistentID: 0, playCount: h.playCount,
      playDateUTC: Date(timeIntervalSince1970: h.playDate.timeIntervalSince1970 + (60 * 60) + 1))

    #expect(t.criteriaApplies(h.albumCriterion))
    #expect(t.criteriaApplies(h.artistCriterion))
    #expect(t.criteriaApplies(h.songCriterion))
    #expect(t.criteriaApplies(h.playCountCriterion))
    #expect(!t.criteriaApplies(h.playDateCriterion))
    #expect(!t.criteriaApplies(h.persistentIDCriterion))
    #expect(!t.criteriaApplies(h.albumPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayDateCriterion))
    #expect(!t.criteriaApplies(h.playCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistCriterion))
    #expect(t.criteriaApplies(h.albumSongCriterion))
    #expect(t.criteriaApplies(h.artistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongCriterion))
    #expect(t.criteriaApplies(h.albumArtistPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistSongPlayCountCriterion))
    #expect(t.criteriaApplies(h.albumPlayCountCriterion))
    #expect(t.criteriaApplies(h.artistPlayCountCriterion))
    #expect(t.criteriaApplies(h.songPlayCountCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistSongPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumArtistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistSongPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.albumPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.artistPlayCountPlayDateCriterion))
    #expect(!t.criteriaApplies(h.songPlayCountPlayDateCriterion))
    #expect(t.criteriaApplies(h.albumArtistSongPlayCountCriterion))
    #expect(!t.criteriaApplies(h.allCriterion))
    #expect(!t.criteriaApplies([]))
  }

  @Test func playCountNil_matchesZero() {
    let t = Track(name: h.song, persistentID: 0)

    #expect(t.criteriaApplies([.playCount(0)]))
  }

  @Test func persistentID() {
    let t = Track(name: h.song, persistentID: 123456)

    #expect(t.criteriaApplies(h.persistentIDCriterion))
  }

  @Test func emptyAlbum() {
    let t = Track(name: "song", persistentID: 123456)

    #expect(!t.criteriaApplies([.album("a")]))
    #expect(t.criteriaApplies([.album("")]))
  }

  @Test func nonMatchingAlbum() {
    let t = Track(album: "b", name: "song", persistentID: 123456)

    #expect(t.criteriaApplies([.album("b")]))
    #expect(!t.criteriaApplies([.album("a")]))
    #expect(!t.criteriaApplies([.album("")]))
  }
}
