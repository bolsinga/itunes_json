//
//  TrackRowEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/4/24.
//

import Foundation
import os

extension Logger {
  static let duplicateArtist = Logger(subsystem: "sql", category: "duplicateArtist")
}

extension Track {
  fileprivate var trackRow: TrackRow {
    let song = rowSong(artist: rowArtist, album: rowAlbum, kind: rowKind)
    return TrackRow(song: song, play: rowPlay(using: song))
  }
}

final class TrackRowEncoder {
  private var songs = Set<TrackRow.SongRow>()
  private var plays = Set<RowPlay<TrackRow.SongRow>>()

  func encode(_ track: Track) {
    let trackRow = track.trackRow
    songs.insert(trackRow.song)
    if let play = trackRow.play {
      plays.insert(play)
    }
  }

  var kindRows: (table: String, rows: [RowKind]) {
    (Track.KindTable, Array(Set(Array(songs).map { $0.kind })).sorted(by: { $0.kind < $1.kind }))
  }

  var artistRows: (table: String, rows: [RowArtist]) {
    let artistRows = Array(Set(Array(songs).map { $0.artist }))

    artistRows.mismatchedSortableNames.forEach {
      Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
    }

    return (Track.ArtistTable, artistRows.sorted(by: { $0.name < $1.name }))
  }

  var albumRows: (table: String, rows: [RowAlbum]) {
    (Track.AlbumTable, Array(Set(Array(songs).map { $0.album })).sorted(by: { $0.name < $1.name }))
  }

  var songRows: (table: String, rows: [TrackRow.SongRow]) {
    (Track.SongTable, Array(songs).sorted(by: { $0.name < $1.name }))
  }

  var playRows: (table: String, rows: [RowPlay<TrackRow.SongRow>]) {
    (Track.PlaysTable, Array(plays).sorted(by: { $0.date < $1.date }))
  }
}
