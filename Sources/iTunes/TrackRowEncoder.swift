//
//  TrackRowEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/4/24.
//

import Foundation
import os

extension Logger {
  static let duplicateArtist = Logger(subsystem: "validation", category: "duplicateArtist")
}

extension Track {
  fileprivate var trackRow: TrackRow {
    TrackRow(album: RowAlbum(self), artist: RowArtist(self), song: RowSong(self), play: rowPlay)
  }
}

final class TrackRowEncoder {
  private var rows = [TrackRow]()

  init(minimumCapacity: Int) {
    self.rows.reserveCapacity(minimumCapacity)
  }

  func encode(_ track: Track) {
    rows.append(track.trackRow)
  }

  var artistRows: (table: String, rows: [RowArtist]) {
    let artistRows = Array(Set(rows.map { $0.artist }))

    artistRows.mismatchedSortableNames.forEach {
      Logger.duplicateArtist.error("\(String(describing: $0), privacy: .public)")
    }

    return (Track.ArtistTable, artistRows.sorted(by: { $0.name < $1.name }))
  }

  var albumRows: (table: String, rows: [RowAlbum]) {
    (Track.AlbumTable, Array(Set(rows.map { $0.album })).sorted(by: { $0.name < $1.name }))
  }

  var songRows: (table: String, rows: [TrackRow]) {
    (Track.SongTable, rows.sorted(by: { $0.song.name < $1.song.name }))
  }

  var playRows: (table: String, rows: [TrackRow]) {
    (Track.PlaysTable, rows.filter { $0.play != nil }.sorted(by: { $0.play!.date < $1.play!.date }))
  }
}
