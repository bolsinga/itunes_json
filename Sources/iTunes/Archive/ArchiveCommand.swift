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

extension Database {
  func archive(into archivePath: String) async throws {
    try self.transaction { db in
      try db.execute("ATTACH DATABASE '\(archivePath)' AS archive;")

      try db.execute(updateArtists)
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

    for try await database in databases {
      Logger.archive.info("\(database.tag)")
      try await database.item.archive(into: await archiveDBPath)
    }
  }
}
