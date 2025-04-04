//
//  AlbumTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct AlbumTableBuilder: TableBuilder {
  private let strictSchema: String = """
    UNIQUE(artistid, name, trackcount, disccount, discnumber, compilation),
    CHECK(length(name) > 0),
    CHECK(name != sortname),
    CHECK(trackcount > 0),
    """

  func schema(constraints: SchemaConstraints) -> String {
    """
    CREATE TABLE albums (
      id INTEGER PRIMARY KEY,
      artistid INTEGER NON NULL,
      name TEXT NOT NULL,
      sortname TEXT NOT NULL DEFAULT '',
      trackcount INTEGER NOT NULL,
      disccount INTEGER NOT NULL,
      discnumber INTEGER NOT NULL,
      compilation INTEGER NOT NULL,
      FOREIGN KEY(artistid) REFERENCES artists(id),
      \(constraints == .strict ? strictSchema : "")
      CHECK(disccount > 0),
      CHECK(discnumber > 0),
      CHECK(compilation = 0 OR compilation = 1)
    );
    """
  }

  let tracks: [TrackRow]

  var rows: [RowAlbum] { Array(Set(tracks.map { $0.album })) }
  var argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  init(tracks: [TrackRow], artistLookup: [RowArtist: Int64]?) {
    self.tracks = tracks.sorted(by: { $0.album.name < $1.album.name })

    if let artistLookup {
      let artistIDs = self.tracks.reduce(into: [RowAlbum: Int64]()) {
        $0[$1.album] = artistLookup[$1.artist] ?? -1
      }

      self.argumentBuilder = {
        $0.insert(artistID: "\(artistIDs[$0])").parameters
      }
    }
  }

  var statements: [Database.Statement] {
    tracks.map { $0.album.insert(artistID: $0.artist.selectID) }
  }
}
