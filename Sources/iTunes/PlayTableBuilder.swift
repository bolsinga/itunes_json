//
//  PlayTableBuilder.swift
//
//
//  Created by Greg Bolsinga on 4/27/24.
//

import Foundation

struct PlayTableBuilder: TableBuilder {
  private let PlaysTable = """
    CREATE TABLE plays (
      id INTEGER PRIMARY KEY,
      songid TEXT NOT NULL,
      date TEXT NOT NULL,
      delta INTEGER NOT NULL,
      UNIQUE(songid, date, delta),
      UNIQUE(date),
      FOREIGN KEY(songid) REFERENCES songs(id),
      CHECK(length(date) > 0),
      CHECK(delta > 0)
    );
    """

  let tracks: [TrackRow]
  var schema: String { PlaysTable }
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
}
