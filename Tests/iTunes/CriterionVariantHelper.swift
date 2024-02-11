//
//  CriterionVariantHelper.swift
//
//
//  Created by Greg Bolsinga on 2/11/24.
//

import Foundation

@testable import iTunes

struct CriterionVariantHelper {
  let album: String
  let artist: String
  let song: String
  let playCount: Int
  let playDate: Date

  var albumCriterion: Set<Criterion> {
    [.album(album)]
  }

  var artistCriterion: Set<Criterion> {
    [.artist(artist)]
  }

  var songCriterion: Set<Criterion> {
    [.song(song)]
  }

  var playCountCriterion: Set<Criterion> {
    [.playCount(playCount)]
  }

  var playDateCriterion: Set<Criterion> {
    [.playDate(playDate)]
  }

  var albumPlayDateCriterion: Set<Criterion> {
    [.album(album), .playDate(playDate)]
  }

  var artistPlayDateCriterion: Set<Criterion> {
    [.artist(artist), .playDate(playDate)]
  }

  var songPlayDateCriterion: Set<Criterion> {
    [.song(song), .playDate(playDate)]
  }

  var playCountPlayDateCriterion: Set<Criterion> {
    [.playCount(playCount), .playDate(playDate)]
  }

  var albumArtistCriterion: Set<Criterion> {
    [.album(album), .artist(artist)]
  }

  var albumSongCriterion: Set<Criterion> {
    [.album(album), .song(song)]
  }

  var artistSongCriterion: Set<Criterion> {
    [.artist(artist), .song(song)]
  }

  var albumArtistSongCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .song(song)]
  }

  var albumArtistPlayCountCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .playCount(playCount)]
  }

  var albumSongPlayCountCriterion: Set<Criterion> {
    [.album(album), .song(song), .playCount(playCount)]
  }

  var artistSongPlayCountCriterion: Set<Criterion> {
    [.artist(artist), .song(song), .playCount(playCount)]
  }

  var albumPlayCountCriterion: Set<Criterion> {
    [.album(album), .playCount(playCount)]
  }

  var artistPlayCountCriterion: Set<Criterion> {
    [.artist(artist), .playCount(playCount)]
  }

  var songPlayCountCriterion: Set<Criterion> {
    [.song(song), .playCount(playCount)]
  }

  var albumArtistPlayDateCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .playDate(playDate)]
  }

  var albumSongPlayDateCriterion: Set<Criterion> {
    [.album(album), .song(song), .playDate(playDate)]
  }

  var artistSongPlayDateCriterion: Set<Criterion> {
    [.artist(artist), .song(song), .playDate(playDate)]
  }

  var albumArtistSongPlayDateCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .song(song), .playDate(playDate)]
  }

  var albumArtistPlayCountPlayDateCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .playCount(playCount), .playDate(playDate)]
  }

  var albumSongPlayCountPlayDateCriterion: Set<Criterion> {
    [.album(album), .song(song), .playCount(playCount), .playDate(playDate)]
  }

  var artistSongPlayCountPlayDateCriterion: Set<Criterion> {
    [.artist(artist), .song(song), .playCount(playCount), .playDate(playDate)]
  }

  var albumPlayCountPlayDateCriterion: Set<Criterion> {
    [.album(album), .playCount(playCount), .playDate(playDate)]
  }

  var artistPlayCountPlayDateCriterion: Set<Criterion> {
    [.artist(artist), .playCount(playCount), .playDate(playDate)]
  }

  var songPlayCountPlayDateCriterion: Set<Criterion> {
    [.song(song), .playCount(playCount), .playDate(playDate)]
  }

  var albumArtistSongPlayCountCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .song(song), .playCount(playCount)]
  }

  var allCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .song(song), .playCount(playCount), .playDate(playDate)]
  }
}
