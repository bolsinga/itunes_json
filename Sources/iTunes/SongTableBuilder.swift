//
//  SongTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct SongTableBuilder: TableBuilder {
  private let strictSchema: String = """
    CHECK(name != sortname),
    CHECK(tracknumber > 0),
    CHECK(year >= 0),
    CHECK(duration > 0)
    """

  private let laxSchema: String = """
    CHECK(name != sortname)
    """

  let tracks: [TrackRow]

  func schema(constraints: SchemaConstraints) -> String {
    // itunesid is TEXT since UInt is bigger than Int64 in sqlite
    """
    CREATE TABLE songs (
      itunesid TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      artistid INTEGER NOT NULL,
      albumid INTEGER NOT NULL,
      composer TEXT NOT NULL DEFAULT '',
      tracknumber INTEGER NOT NULL,
      year INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      dateadded TEXT NOT NULL,
      datereleased TEXT NOT NULL DEFAULT '',
      comments TEXT NOT NULL DEFAULT '',
      UNIQUE(itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, dateadded, datereleased, comments),
      FOREIGN KEY(artistid) REFERENCES artists(id),
      FOREIGN KEY(albumid) REFERENCES albums(id),
      CHECK(length(name) > 0),
      \(constraints == .strict ? strictSchema : laxSchema)
    );
    """
  }

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

  var statements: [Database.Statement] {
    tracks.map { $0.song.insert(artistID: $0.artist.selectID, albumID: $0.album.selectID) }
  }
}
