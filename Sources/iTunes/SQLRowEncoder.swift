//
//  SQLRowEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/4/24.
//

import Foundation
import os

extension Logger {
  static let duplicateArtist = Logger(subsystem: "sql", category: "duplicateArtist")
}

typealias SongRow = RowSong<RowArtist, RowAlbum, RowKind>

extension Track {
  fileprivate var rows: (song: SongRow, play: RowPlay<SongRow>?) {
    let song = rowSong(artist: rowArtist, album: rowAlbum, kind: rowKind)
    return (song: song, play: rowPlay(using: song))
  }
}

final class SQLRowEncoder {
  private var songs = Set<SongRow>()
  private var plays = Set<RowPlay<SongRow>>()

  func encode(_ track: Track) {
    let rows = track.rows
    songs.insert(rows.song)
    if let play = rows.play {
      plays.insert(play)
    }
  }

  var kindRows: (table: String, rows: [RowKind]) {
    (Track.KindTable, Array(Set(Array(songs).map { $0.kind })))
  }

  var artistRows: (table: String, rows: [RowArtist]) {
    let artistRows = Array(Set(Array(songs).map { $0.artist }))

    artistRows.mismatchedSortableNames.forEach {
      Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
    }

    return (Track.ArtistTable, artistRows)
  }

  var albumRows: (table: String, rows: [RowAlbum]) {
    (Track.AlbumTable, Array(Set(Array(songs).map { $0.album })))
  }

  var songRows: (table: String, rows: [SongRow]) {
    (Track.SongTable, Array(songs))
  }

  var playRows: (table: String, rows: [RowPlay<SongRow>]) {
    (Track.PlaysTable, Array(plays))
  }
}
