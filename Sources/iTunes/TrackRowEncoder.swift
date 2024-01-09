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
    return TrackRow(song: song, play: rowPlay)
  }
}

final class TrackRowEncoder {
  private var rows = [TrackRow]()
  private var songs = Set<TrackRow.SongRow>()

  func encode(_ track: Track) {
    let trackRow = track.trackRow
    rows.append(trackRow)

    songs.insert(trackRow.song)
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

  var playRows: (table: String, rows: [TrackRow]) {
    (Track.PlaysTable, rows.filter { $0.play != nil }.sorted(by: { $0.play!.date < $1.play!.date }))
  }
}
