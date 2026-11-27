//
//  FlatTrackRow.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

struct FlatTrackRow: FlatRow {
  let track: Track
  fileprivate let tracknumber: Int
  fileprivate let trackcount: Int
  fileprivate let year: Int
  fileprivate let duration: Int

  init(track: Track) throws {
    self.track = track
    self.tracknumber = try track.requiredNumber(\.trackNumber)
    self.trackcount = try track.requiredNumber(\.trackCount)
    self.year = try track.requiredNumber(\.year)
    self.duration = try track.requiredNumber(\.totalTime)
  }

  fileprivate var itunesid: String { String(track.persistentID) }
  fileprivate var name: String { track.songName.name }
  fileprivate var sortname: String { track.songName.sorted }
  fileprivate var artist: String { track.artistName?.name ?? "" }
  fileprivate var sortartist: String { track.artistName?.sorted ?? "" }
  fileprivate var album: String { track.albumName?.name ?? "" }
  fileprivate var sortalbum: String { track.albumName?.sorted ?? "" }
  fileprivate var disccount: Int { track.albumDiscCount }
  fileprivate var discnumber: Int { track.albumDiscNumber }
  fileprivate var dateadded: String { track.dateAddedISO8601 }
  fileprivate var compilation: Int { (track.compilation ?? false) ? 1 : 0 }
  fileprivate var composer: String { track.composer ?? "" }
  fileprivate var datereleased: String { track.dateReleasedISO8601 }
  fileprivate var comments: String { track.comments ?? "" }
  fileprivate var playdate: String { track.datePlayedISO8601 }
  fileprivate var playcount: Int { track.playCount ?? 0 }

  private var insert: Database.Statement {
    """
    INSERT INTO tracks (itunesid, name, sortname, artist, sortartist, album, sortalbum, tracknumber, trackcount, disccount, discnumber, year, duration, dateadded, compilation, composer, datereleased, comments, playdate, playcount)
    VALUES (\(itunesid), \(name), \(sortname), \(artist), \(sortartist), \(album), \(sortalbum), \(tracknumber), \(trackcount), \(disccount), \(discnumber), \(year), \(duration), \(dateadded), \(compilation), \(composer), \(datereleased), \(comments), \(playdate), \(playcount));
    """
  }

  static func insertStatement(_ first: Track) throws -> Database.Statement {
    try FlatTrackRow(track: first).insert
  }

  var parameters: [Database.Value] {
    insert.parameters
  }
}
