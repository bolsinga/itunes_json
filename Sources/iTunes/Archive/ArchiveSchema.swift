//
//  ArchiveSchema.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/28/26.
//

import Foundation

/// The tables and views of the derived archive. See RFC 0005, "Schema changes".
enum ArchiveSchema {
  /// The version written to `archivestate`. Change it when the tables change.
  static let version = "1"

  /// The tables that verifying compares, with the rows of each that are compared. The tool
  /// version is not compared, because it says which build wrote the archive.
  static let comparedTables: [(table: String, filter: String)] = [
    ("artists", ""), ("albums", ""), ("songs", ""), ("added", ""), ("released", ""),
    ("plays", ""), ("playstate", ""), ("findings", ""),
    ("archivestate", "WHERE key != 'toolversion'"),
  ]

  /// itunesid is TEXT since UInt is bigger than Int64 in sqlite.
  static let tables = """
    CREATE TABLE IF NOT EXISTS artists (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      sortname TEXT NOT NULL DEFAULT '',
      CHECK(length(name) > 0),
      CHECK(name != sortname)
    ) STRICT;
    CREATE TABLE IF NOT EXISTS albums (
      id INTEGER PRIMARY KEY,
      artistid INTEGER NOT NULL,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      trackcount INTEGER NOT NULL,
      disccount INTEGER NOT NULL,
      discnumber INTEGER NOT NULL,
      compilation INTEGER NOT NULL,
      UNIQUE(artistid, name, trackcount, disccount, discnumber, compilation),
      FOREIGN KEY(artistid) REFERENCES artists(id),
      CHECK(length(name) > 0),
      CHECK(name != sortname),
      CHECK(trackcount > 0),
      CHECK(disccount > 0),
      CHECK(discnumber > 0),
      CHECK(compilation = 0 OR compilation = 1)
    ) STRICT;
    CREATE TABLE IF NOT EXISTS songs (
      itunesid TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      artistid INTEGER NOT NULL,
      albumid INTEGER NOT NULL,
      composer TEXT NOT NULL DEFAULT '',
      tracknumber INTEGER NOT NULL,
      year INTEGER NOT NULL,
      duration INTEGER NOT NULL,
      comments TEXT NOT NULL DEFAULT '',
      lastseen TEXT NOT NULL,
      UNIQUE(itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, comments),
      FOREIGN KEY(artistid) REFERENCES artists(id),
      FOREIGN KEY(albumid) REFERENCES albums(id),
      CHECK(length(name) > 0),
      CHECK(name != sortname),
      CHECK(tracknumber > 0),
      CHECK(year > 0),
      CHECK(duration > 0),
      CHECK(length(lastseen) > 0)
    ) STRICT;
    CREATE TABLE IF NOT EXISTS added (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT NOT NULL
    ) STRICT;
    CREATE TABLE IF NOT EXISTS released (
      itunesid TEXT NOT NULL PRIMARY KEY,
      date TEXT NOT NULL
    ) STRICT;
    CREATE TABLE IF NOT EXISTS plays (
      id INTEGER PRIMARY KEY,
      itunesid TEXT NOT NULL,
      date TEXT NOT NULL,
      delta INTEGER NOT NULL,
      count INTEGER NOT NULL,
      tag TEXT NOT NULL,
      UNIQUE(itunesid, date),
      FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
      CHECK(length(date) > 0),
      CHECK(delta > 0),
      CHECK(count >= delta)
    ) STRICT;
    CREATE TABLE IF NOT EXISTS playstate (
      itunesid TEXT NOT NULL PRIMARY KEY,
      seencount INTEGER NOT NULL,
      seendate TEXT NOT NULL,
      FOREIGN KEY(itunesid) REFERENCES songs(itunesid)
    ) STRICT;
    CREATE TABLE IF NOT EXISTS findings (
      id INTEGER PRIMARY KEY,
      tag TEXT NOT NULL,
      itunesid TEXT,
      code TEXT NOT NULL,
      detail TEXT NOT NULL
    ) STRICT;
    CREATE TABLE IF NOT EXISTS archivestate (
      key TEXT NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    ) STRICT;
    """

  static let views = """
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
      al.disccount AS disccount,
      al.discnumber AS discnumber,
      s.year AS year,
      s.duration AS duration,
      da.date AS dateadded,
      al.compilation AS compilation,
      s.composer AS composer,
      COALESCE(dr.date, '') AS datereleased,
      s.comments AS comments,
      p.date AS playdate,
      p.count AS playcount
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
    CREATE VIEW IF NOT EXISTS removedsongs AS
      SELECT * FROM songs
      WHERE lastseen != (SELECT value FROM archivestate WHERE key = 'lasttag')
    ;
    CREATE VIEW IF NOT EXISTS sharedplaydates AS
      SELECT date, COUNT(*) AS songs FROM plays GROUP BY date HAVING COUNT(*) > 1
    ;
    """
}
