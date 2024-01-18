//
//  Track+SQLSchema.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

extension Track {
  static let KindTable = "CREATE TABLE kinds (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE);"

  static let ArtistTable = """
    CREATE TABLE artists (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      sortname TEXT NOT NULL DEFAULT '',
      CHECK(length(name) > 0),
      CHECK(name != sortname)
    );
    """

  static let AlbumTable = """
    CREATE TABLE albums (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      trackcount INTEGER NOT NULL,
      disccount INTEGER NOT NULL,
      discnumber INTEGER NOT NULL,
      compilation INTEGER NOT NULL,
      UNIQUE(name, trackcount, disccount, discnumber, compilation),
      CHECK(length(name) > 0),
      CHECK(name != sortname),
      CHECK(trackcount > 0),
      CHECK(disccount > 0),
      CHECK(discnumber > 0),
      CHECK(compilation = 0 OR compilation = 1)
    );
    """

  // itunesid is TEXT since UInt is bigger than Int64 in sqlite
  static let SongTable = """
    CREATE TABLE songs (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      itunesid TEXT NOT NULL,
      artistid INTEGER NOT NULL,
      albumid INTEGER NOT NULL,
      kindid INTEGER NOT NULL,
      composer TEXT NOT NULL DEFAULT '',
      tracknumber INTEGER NOT NULL,
      year INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      dateadded TEXT NOT NULL,
      datereleased TEXT NOT NULL DEFAULT '',
      comments TEXT NOT NULL DEFAULT '',
      UNIQUE(name, sortname, itunesid, artistid, albumid, kindid, composer, tracknumber, year, duration, dateadded, datereleased, comments),
      FOREIGN KEY(artistid) REFERENCES artists(id),
      FOREIGN KEY(albumid) REFERENCES albums(id),
      FOREIGN KEY(kindid) REFERENCES kinds(id),
      CHECK(length(name) > 0),
      CHECK(name != sortname),
      CHECK(tracknumber > 0),
      CHECK(year >= 0),
      CHECK(duration > 0)
    );
    """

  static let PlaysTable = """
    CREATE TABLE plays (
      id INTEGER PRIMARY KEY,
      songid TEXT NOT NULL,
      date TEXT NOT NULL,
      delta INTEGER NOT NULL,
      UNIQUE(songid, date, delta),
      FOREIGN KEY(songid) REFERENCES songs(id),
      CHECK(delta >= 0)
    );
    """
}
