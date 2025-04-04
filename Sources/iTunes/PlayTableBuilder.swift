//
//  PlayTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct PlayTableBuilder: TableBuilder {
  private let strictSchema: String = """
    UNIQUE(songid, date, delta),
    UNIQUE(date),
    FOREIGN KEY(songid) REFERENCES songs(id),
    CHECK(length(date) > 0),
    CHECK(delta > 0)
    """

  private let laxSchema: String = """
    FOREIGN KEY(songid) REFERENCES songs(id)
    """

  let tracks: [TrackRow]

  func schema(constraints: SchemaConstraints) -> String {
    """
    CREATE TABLE plays (
      id INTEGER PRIMARY KEY,
      songid TEXT NOT NULL,
      date TEXT NOT NULL,
      delta INTEGER NOT NULL,
      \(constraints == .strict ? strictSchema : laxSchema)
    );
    """
  }

  var rows: [RowPlay] { tracks.map { $0.play! } }
  var argumentBuilder: (@Sendable (Row) -> [Database.Value])?

  init(tracks: [TrackRow], songLookup: [RowSong: Int64]? = nil) {
    self.tracks = tracks.sorted(by: { $0.play!.date < $1.play!.date })
    if let songLookup {
      let songIDs = tracks.reduce(into: [RowPlay: Int64]()) {
        $0[$1.play] = songLookup[$1.song] ?? -1
      }
      self.argumentBuilder = { $0.insert(songid: "\(songIDs[$0])").parameters }
    }
  }

  var statements: [Database.Statement] {
    tracks.map {
      $0.play!.insert(
        songid: $0.song.selectID(artistID: $0.artist.selectID, albumID: $0.album.selectID))
    }
  }
}
