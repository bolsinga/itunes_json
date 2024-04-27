//
//  SongTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct SongTableBuilder: TableBuilder {
  // itunesid is TEXT since UInt is bigger than Int64 in sqlite
  private let SongTable = """
    CREATE TABLE songs (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      itunesid TEXT NOT NULL,
      artistid INTEGER NOT NULL,
      albumid INTEGER NOT NULL,
      composer TEXT NOT NULL DEFAULT '',
      tracknumber INTEGER NOT NULL,
      year INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      dateadded TEXT NOT NULL,
      datereleased TEXT NOT NULL DEFAULT '',
      comments TEXT NOT NULL DEFAULT '',
      UNIQUE(name, sortname, itunesid, artistid, albumid, composer, tracknumber, year, duration, dateadded, datereleased, comments),
      FOREIGN KEY(artistid) REFERENCES artists(id),
      FOREIGN KEY(albumid) REFERENCES albums(id),
      CHECK(length(name) > 0),
      CHECK(name != sortname),
      CHECK(tracknumber > 0),
      CHECK(year >= 0),
      CHECK(duration > 0)
    );
    """

  let tracks: [TrackRow]
  var schema: String { SongTable }
  var rows: [RowSong] { tracks.map { $0.song } }
  var argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  init(tracks: [TrackRow], artistLookup: [RowArtist: Int64]?, albumLookup: [RowAlbum: Int64]?) {
    self.tracks = tracks.sorted(by: { $0.song.name < $1.song.name })

    if let artistLookup, let albumLookup {
      let artistIDs = self.tracks.reduce(into: [RowSong: Int64]()) {
        $0[$1.song] = artistLookup[$1.artist] ?? -1
      }

      let albumIDs = self.tracks.reduce(into: [RowSong: Int64]()) {
        $0[$1.song] = albumLookup[$1.album] ?? -1
      }

      self.argumentBuilder = {
        $0.insert(artistID: "\(artistIDs[$0])", albumID: "\(albumIDs[$0])").parameters
      }
    }
  }
}
