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

  var allCriterion: Set<Criterion> {
    [.album(album), .artist(artist), .song(song), .playCount(playCount)]
  }
}
