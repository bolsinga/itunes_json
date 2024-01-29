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

struct TrackRowEncoder {
  let rows: [TrackRow]

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

  var views = """
    CREATE VIEW tracks AS
    SELECT
      s.id AS sid,
      s.name AS song,
      s.trackNumber AS track,
      a.id AS aid,
      a.name AS artist,
      al.id AS alid,
      al.name AS album,
      p.id AS pid,
      p.date AS date,
      p.delta as delta
    FROM songs s
    LEFT JOIN artists a ON s.artistid=a.id
    LEFT JOIN albums al ON s.albumid=al.id
    LEFT JOIN plays p ON s.id=p.songid
    ;
    """
}
