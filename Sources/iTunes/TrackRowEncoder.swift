//
//  TrackRowEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/4/24.
//

import Foundation
import os

extension RowAlbum {
  var debugLogInformation: String {
    "name: \(name.name) trackCount: \(trackCount)"
  }
}

extension RowArtist {
  var debugLogInformation: String {
    "name: \(name.name)"
  }
}

extension RowSong {
  var debugLogInformation: String {
    "name: \(name.name) id: \(itunesid) track: \(trackNumber) year: \(year)"
  }
}

extension RowPlay {
  var debugLogInformation: String {
    "date: \(date) delta: \(delta)"
  }
}

extension TrackRow {
  var debugLogInformation: String {
    "album: [\(album.debugLogInformation)], artist: (\(artist.debugLogInformation)), song: (\(song.debugLogInformation)), play: (\(play?.debugLogInformation ?? "n/a"))"
  }
}

struct TrackRowEncoder {
  let rows: [TrackRow]
  let validation: TrackValidation

  var artistRows: (table: String, rows: [RowArtist]) {
    let artistRows = Array(Set(rows.map { $0.artist }))

    let mismatched = artistRows.mismatchedSortableNames
    if !mismatched.isEmpty {
      mismatched.forEach {
        validation.duplicateArtist.error("\($0, privacy: .public)")
      }
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
    let playRows = rows.filter { $0.play != nil }

    let duplicates = playRows.duplicatePlayDates
    if !duplicates.isEmpty {
      duplicates.forEach {
        validation.duplicatePlayDate.error("\($0.debugLogInformation, privacy: .public)")
      }
    }

    return (Track.PlaysTable, playRows.sorted(by: { $0.play!.date < $1.play!.date }))
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
