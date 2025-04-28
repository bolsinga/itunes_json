//
//  ArchiveCommand.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 4/6/25.
//

import ArgumentParser
import Foundation
import os

extension Logger {
  fileprivate static let archive = Logger(category: "archive")
}

private let updateArtists: String =
  """
  -- Create a table of itunesid to artist names
  CREATE TEMPORARY TABLE new_names (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '');
  -- Insert all the new artist names and itunesids
  INSERT INTO new_names (itunesid, name, sortname) SELECT itunesid, artist, sortartist FROM tracks EXCEPT SELECT artist_ids.itunesid, ara.name, ara.sortname FROM archive.artists ara LEFT JOIN archive.artistids artist_ids ON ara.id = artist_ids.artistid;
  -- Fix new names to be name, sortname if some are set and some are not.
  UPDATE new_names AS a SET sortname = n.sortname FROM (WITH names AS (SELECT DISTINCT name, sortname FROM new_names) SELECT DISTINCT a.name AS name, COALESCE(NULLIF(a.sortname, ''), NULLIF(o.sortname, ''), '') AS sortname FROM names a LEFT JOIN names o ON a.name=o.name AND a.sortname!=o.sortname ORDER BY name) AS n WHERE a.name = n.name AND a.sortname != n.sortname;
  -- Update any changed artist names.
  UPDATE archive.artists AS a SET name = new.name, sortname = new.sortname FROM (SELECT DISTINCT ar.id, new.name, new.sortname FROM archive.artistids artist_ids INNER JOIN new_names new ON new.itunesid = artist_ids.itunesid INNER JOIN archive.artists ar ON ar.id = artist_ids.artistid) AS new WHERE a.id = new.id;
  -- Insert all the new artist names (even if an existing artist has a new itunesid)
  INSERT INTO archive.artists (name, sortname) SELECT DISTINCT name, sortname FROM new_names EXCEPT SELECT name, sortname FROM archive.artists;
  -- Insert all the new itunesid and artistids that aren't already present, in case of an artist name update.
  INSERT INTO archive.artistids (itunesid, artistid) SELECT DISTINCT new.itunesid, a.id FROM new_names new LEFT JOIN archive.artists a ON new.name = a.name AND new.sortname = a.sortname EXCEPT SELECT artist_ids.itunesid, artist_ids.artistid FROM archive.artistids artist_ids;
  DROP TABLE new_names;
  """

private let updateAlbums: String =
  """
  -- Create a table of itunesid to album data
  CREATE TEMPORARY TABLE changed_albums (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', trackcount INTEGER NOT NULL, disccount INTEGER NOT NULL, discnumber INTEGER NOT NULL, compilation INTEGER NOT NULL);
  -- Insert all the new album data
  INSERT INTO changed_albums (itunesid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT itunesid, album, sortalbum, trackcount, disccount, discnumber, compilation FROM tracks EXCEPT SELECT album_ids.itunesid, ara.name, ara.sortname, ara.trackcount, ara.disccount, ara.discnumber, ara.compilation FROM archive.albums ara LEFT JOIN archive.albumids album_ids ON ara.id = album_ids.albumid;
  -- Fix new names to be name, sortname if some are set and some are not.
  UPDATE changed_albums AS a SET sortname = n.sortname FROM (WITH names AS (SELECT DISTINCT name, sortname FROM changed_albums) SELECT DISTINCT a.name AS name, COALESCE(NULLIF(a.sortname, ''), NULLIF(o.sortname, ''), '') AS sortname FROM names a LEFT JOIN names o ON a.name=o.name AND a.sortname!=o.sortname ORDER BY name) AS n WHERE a.name = n.name AND a.sortname != n.sortname;
  CREATE TEMPORARY TABLE new_albums (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', trackcount INTEGER NOT NULL, disccount INTEGER NOT NULL, discnumber INTEGER NOT NULL, compilation INTEGER NOT NULL);
  INSERT INTO new_albums (itunesid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT * FROM changed_albums new WHERE itunesid NOT IN (SELECT itunesid FROM archive.albumids);
  CREATE TEMPORARY TABLE updated_albums (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', trackcount INTEGER NOT NULL, disccount INTEGER NOT NULL, discnumber INTEGER NOT NULL, compilation INTEGER NOT NULL);
  INSERT INTO updated_albums (itunesid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT * FROM changed_albums new WHERE itunesid IN (SELECT itunesid FROM archive.albumids);
  DROP TABLE changed_albums;
  -- Update albums that change to existing albums (ie trackcount for one track of an album is fixed; the correct album already exists!)
  UPDATE archive.albumids AS ualids SET albumid = n.id FROM (SELECT updated.itunesid, album.id FROM updated_albums updated LEFT JOIN archive.albums album ON updated.name = album.name AND updated.sortname = album.sortname AND updated.trackcount = album.trackcount AND updated.disccount = album.disccount AND updated.discnumber = album.discnumber AND updated.compilation = album.compilation LEFT JOIN archive.albumids alids ON alids.itunesid = updated.itunesid AND alids.albumid = album.id WHERE id IS NOT NULL) AS n WHERE ualids.itunesid = n.itunesid;
  -- Update any changed album data.
  UPDATE archive.albums AS a SET name = new.name, sortname = new.sortname, trackcount = new.trackcount, disccount = new.disccount, discnumber = new.discnumber, compilation = new.compilation FROM (SELECT DISTINCT al.id, new.name, new.sortname, new.trackcount, new.disccount, new.discnumber, new.compilation FROM archive.albumids album_ids INNER JOIN updated_albums new ON new.itunesid = album_ids.itunesid INNER JOIN archive.albums al ON al.id = album_ids.albumid) AS new WHERE a.id = new.id;
  -- Insert all the new album data
  INSERT INTO archive.albums (artistid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT DISTINCT arid.artistid, name, sortname, trackcount, disccount, discnumber, compilation FROM new_albums n LEFT JOIN artistids arid ON n.itunesid = arid.itunesid EXCEPT SELECT artistid, name, sortname, trackcount, disccount, discnumber, compilation FROM archive.albums;
  -- Insert all the new itunesid and albumids that aren't already present, in case of an album data update.
  INSERT INTO archive.albumids (itunesid, albumid) SELECT new.itunesid, a.id FROM new_albums new INNER JOIN archive.albums a ON new.name = a.name AND new.sortname = a.sortname AND new.trackcount = a.trackcount AND new.disccount = a.disccount AND new.discnumber = a.discnumber AND new.compilation = a.compilation INNER JOIN archive.artistids ar ON a.artistid = ar.artistid AND ar.itunesid = new.itunesid EXCEPT SELECT album_ids.itunesid, album_ids.albumid FROM archive.albumids album_ids;
  -- Remove unused albums
  DELETE FROM archive.albums AS al WHERE al.id NOT IN (SELECT albumid FROM archive.albumids);
  DROP TABLE new_albums;
  DROP TABLE updated_albums;
  """

private let updateAdded: String =
  "INSERT OR IGNORE INTO added (itunesid, date) SELECT itunesid, dateadded FROM tracks;"

private let updateReleased: String =
  "INSERT OR IGNORE INTO released (itunesid, date) SELECT itunesid, datereleased FROM tracks WHERE datereleased != '';"

private let updateSongs =
  """
    CREATE TEMPORARY TABLE changed_songs (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', composer TEXT NOT NULL DEFAULT '', tracknumber INTEGER NOT NULL, year INTEGER NOT NULL, duration INTEGER NOT NULL, comments TEXT NOT NULL DEFAULT '');
    -- Insert all the new song data
    INSERT INTO changed_songs (itunesid, name, sortname, composer, tracknumber, year, duration, comments) SELECT itunesid, name, sortname, composer, tracknumber, year, duration, comments FROM tracks EXCEPT SELECT ars.itunesid, ars.name, ars.sortname, ars.composer, ars.tracknumber, ars.year, ars.duration, ars.comments FROM archive.songs ars;
    UPDATE changed_songs AS a SET sortname = n.sortname FROM (WITH names AS (SELECT DISTINCT name, sortname FROM changed_songs) SELECT DISTINCT a.name AS name, COALESCE(NULLIF(a.sortname, ''), NULLIF(o.sortname, ''), '') AS sortname FROM names a LEFT JOIN names o ON a.name=o.name AND a.sortname!=o.sortname ORDER BY name) AS n WHERE a.name = n.name AND a.sortname != n.sortname;

    CREATE TEMPORARY TABLE new_songs (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', composer TEXT NOT NULL DEFAULT '', tracknumber INTEGER NOT NULL, year INTEGER NOT NULL, duration INTEGER NOT NULL, comments TEXT NOT NULL DEFAULT '');
    INSERT INTO new_songs (itunesid, name, sortname, composer, tracknumber, year, duration, comments) SELECT * FROM changed_songs new WHERE itunesid NOT IN (SELECT itunesid FROM archive.songs);
    CREATE TEMPORARY TABLE updated_songs (itunesid TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, sortname TEXT NOT NULL DEFAULT '', composer TEXT NOT NULL DEFAULT '', tracknumber INTEGER NOT NULL, year INTEGER NOT NULL, duration INTEGER NOT NULL, comments TEXT NOT NULL DEFAULT '');
    INSERT INTO updated_songs (itunesid, name, sortname, composer, tracknumber, year, duration, comments) SELECT * FROM changed_songs new WHERE itunesid IN (SELECT itunesid FROM archive.songs);
    DROP TABLE changed_songs;

    UPDATE archive.songs AS a SET name = new.name, sortname = new.sortname, composer = new.composer, tracknumber = new.tracknumber, year = new.year, duration = new.duration, comments = new.comments FROM (SELECT * FROM updated_songs) AS new WHERE a.itunesid = new.itunesid;

    INSERT INTO archive.songs (itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, comments) SELECT n.itunesid, n.name, n.sortname, arid.artistid, alid.albumid, n.composer, n.tracknumber, n.year, n.duration, n.comments FROM new_songs n INNER JOIN archive.artistids arid ON arid.itunesid = n.itunesid INNER JOIN archive.albumids alid ON alid.itunesid = n.itunesid;
    DROP TABLE new_songs;
    DROP TABLE updated_songs;
  """

private let updatePlays =
  """
  CREATE TEMPORARY TABLE non_empty_tracks (itunesid TEXT NOT NULL, date TEXT NOT NULL, count INTEGER NOT NULL);
  INSERT INTO non_empty_tracks (itunesid, date, count) SELECT itunesid, playdate, playcount FROM tracks WHERE playdate != '';

  -- Handle duplicate dates from the same album in the source data. Find the earlier tracknumber's duration and add it to the timestamp of the previous date.
  CREATE TEMPORARY TABLE no_duplicate_date_tracks (itunesid TEXT NOT NULL, date TEXT NOT NULL, count INTEGER NOT NULL);
  WITH no_duplicate_date_albums AS (WITH fix_duplicate_date_albums AS (WITH duplicate_date_albums AS (WITH duplicate_dates AS (SELECT * FROM non_empty_tracks WHERE date IN (SELECT date FROM non_empty_tracks GROUP BY date HAVING COUNT(*) > 1)) SELECT dd.itunesid, dd.date, dd.count, s.albumid FROM duplicate_dates dd INNER JOIN archive.songs s ON s.itunesid = dd.itunesid) SELECT * FROM duplicate_date_albums dda WHERE albumid IN (SELECT albumid FROM duplicate_date_albums GROUP BY albumid HAVING COUNT(*) > 1)) SELECT a.itunesid, a.date AS date, a.count, CASE WHEN sa.tracknumber + 1 = sb.tracknumber THEN a.date ELSE strftime('%Y-%m-%dT%H:%M:%SZ', datetime(strftime('%s', b.date) + ROUND(sa.duration / 1000), 'unixepoch')) END fixdate FROM fix_duplicate_date_albums a INNER JOIN fix_duplicate_date_albums b ON a.date = b.date AND a.albumid = b.albumid INNER JOIN archive.songs sa ON sa.itunesid = a.itunesid INNER JOIN archive.songs sb ON sb.itunesid = b.itunesid AND sa.tracknumber != sb.tracknumber) INSERT INTO no_duplicate_date_tracks (itunesid, date, count) SELECT itunesid, fixdate AS date, count FROM no_duplicate_date_albums WHERE date != fixdate;
  UPDATE non_empty_tracks AS a SET date = new.date FROM (SELECT * FROM no_duplicate_date_tracks) AS new WHERE a.itunesid = new.itunesid;

  CREATE TEMPORARY TABLE changed_no_quirk_tracks (itunesid TEXT NOT NULL, date TEXT NOT NULL, count INTEGER NOT NULL);
  WITH non_empty_offset_tracks AS (SELECT a.itunesid, a.count, a.date AS adate, b.date AS bdate, ABS(strftime('%s', a.date) - strftime('%s', b.date)) AS difference FROM non_empty_tracks a LEFT JOIN archive.lastplays b ON a.itunesid=b.itunesid WHERE difference IS NULL OR difference > 0) INSERT INTO changed_no_quirk_tracks (itunesid, date, count) SELECT itunesid, CASE WHEN difference IS NOT NULL AND difference < 12 * 60 * 60 AND MOD(difference, 60 * 60) = 0 THEN bdate ELSE adate END AS date, count FROM non_empty_offset_tracks;
  DROP TABLE non_empty_tracks;

  INSERT INTO archive.plays (itunesid, date, count) SELECT * FROM changed_no_quirk_tracks EXCEPT SELECT arp.itunesid, arp.date, arp.count FROM archive.lastplays AS arp;
  DROP TABLE changed_no_quirk_tracks;
  """

extension Database {
  func archive(into archivePath: String) async throws {
    try self.execute("ATTACH DATABASE '\(archivePath)' AS archive;")

    try self.transaction { db in
      try db.execute(updateArtists)
    }
    try self.transaction { db in
      try db.execute(updateAlbums)
    }
    try self.transaction { db in
      try db.execute(updateAdded)
    }
    try self.transaction { db in
      try db.execute(updateReleased)
    }
    try self.transaction { db in
      try db.execute(updateSongs)
    }
    try self.transaction { db in
      try db.execute(updatePlays)
    }
  }
}

struct ArchiveCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "archive",
    abstract: "Create a normalized archive database from a git repository.",
    version: iTunesVersion
  )

  @Flag(help: "Pass true if the archive database should be emptied before running.")
  var clear: Bool = false

  /// Lax normalized database schema table constraints.
  @Flag(help: "Lax normalized database schema table constraints")
  var laxSchema: [SchemaFlag] = []

  /// Git Directory to read and write data from.
  @Option(
    help: "The path for the git directory to work with.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var gitDirectory: URL

  /// Output Directory for batch results.
  @Option(
    help: "The path at which to create the archive database.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }

      return url
    })
  )
  var outputDirectory: URL

  /// Optional file name to use.
  @Option(help: "File name to use when outputDirectory is used.")
  var fileName: String = "itunes"

  /// Outputfile where data will be writen, if outputDirectory is not specified.
  private var outputFile: URL {
    return outputDirectory.appending(path: fileName).appendingPathExtension("db")
  }

  func run() async throws {
    if clear { _ = try? FileManager.default.removeItem(at: outputFile) }

    let format = DatabaseFormat.normalized(
      DatabaseContext(storage: .file(outputFile), schemaOptions: laxSchema.schemaOptions))
    let archiveDB = try await format.database(tracks: [])

    let databases = gitDirectory.backupFile.databases(
      .flat(FlatTracksDatabaseContext(storage: .memory)))

    async let archiveDBPath = archiveDB.filename

    for database in try await databases.reduce(into: [Tag<Database>](), { $0.append($1) }).sorted(
      by: {
        $0.tag < $1.tag
      })
    {
      Logger.archive.info("\(database.tag)")
      try await database.item.archive(into: await archiveDBPath)
    }
  }
}
