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
    "date: \(date) delta: \(count)"
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

  var artistTableBuilder: ArtistTableBuilder {
    let artistRows = Array(Set(rows.map { $0.artist }))

    artistRows.mismatchedSortableNames.forEach {
      validation.duplicateArtist.error("\($0, privacy: .public)")
    }

    return ArtistTableBuilder(rows: artistRows)
  }

  func albumTableBuilder(artistLookup: [RowArtist: Int64]? = nil) -> AlbumTableBuilder {
    AlbumTableBuilder(tracks: rows, artistLookup: artistLookup)
  }

  func songTableBuilder(
    artistLookup: [RowArtist: Int64]? = nil, albumLookup: [RowAlbum: Int64]? = nil
  )
    -> SongTableBuilder
  {
    SongTableBuilder(tracks: rows, artistLookup: artistLookup, albumLookup: albumLookup)
  }

  var addedTableBuilder: AddedTableBuilder {
    AddedTableBuilder(rows: rows.map { $0.add })
  }

  var releasedTableBuilder: ReleasedTableBuilder {
    ReleasedTableBuilder(rows: rows.map { $0.release })
  }

  var playTableBuilder: PlayTableBuilder {
    let playRows = rows.filter { $0.play != nil }

    playRows.duplicatePlayDates.forEach {
      validation.duplicatePlayDate.error("\($0.debugLogInformation, privacy: .public)")
    }

    return PlayTableBuilder(tracks: playRows)
  }

  var views = """
    CREATE VIEW IF NOT EXISTS tracks AS
    SELECT
      s.itunesid AS itunesid,
      s.name AS name,
      s.sortname AS sortname,
      a.name AS artist,
      a.sortname AS sortartist,
      al.name AS album,
      al.sortname AS sortalbum,
      s.tracknumber AS tracknumber,
      al.trackcount AS trackcount,
      al.disccount AS discount,
      al.discnumber AS discnumber,
      s.year AS year,
      s.duration AS duration,
      da.date AS dateadded,
      al.compilation AS compilation,
      s.composer AS composer,
      COALESCE(dr.date, '') AS datereleased,
      s.comments AS comments,
      p.date AS playdate,
      p.count AS count
    FROM songs s
    LEFT JOIN artists a ON s.artistid=a.id
    LEFT JOIN albums al ON s.albumid=al.id
    LEFT JOIN plays p ON s.itunesid=p.itunesid
    LEFT JOIN added da ON s.itunesid=da.itunesid
    LEFT JOIN released dr ON s.itunesid=dr.itunesid
    ;
    CREATE VIEW IF NOT EXISTS lastplays AS
      SELECT itunesid, date, count
        FROM (
          SELECT *, RANK() OVER (PARTITION BY itunesid ORDER BY date DESC) AS filter FROM plays
        ) AS foo
      WHERE filter = 1
    ;
    """
}
