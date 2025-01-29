//
//  FlatTrackRow.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

struct FlatTrackRow {
  let track: Track

  fileprivate var itunesid: String { String(track.persistentID) }
  fileprivate var name: String { track.name }
  fileprivate var sortname: String { track.sortName ?? "" }
  fileprivate var artist: String { track.artist ?? "" }
  fileprivate var sortartist: String { track.sortArtist ?? "" }
  fileprivate var album: String { track.album ?? "" }
  fileprivate var sortalbum: String { track.sortAlbum ?? "" }
  fileprivate var tracknumber: Int { track.trackNumber ?? 0 }
  fileprivate var trackcount: Int { track.trackCount ?? 0 }
  fileprivate var disccount: Int { track.discCount ?? 0 }
  fileprivate var discnumber: Int { track.discNumber ?? 0 }
  fileprivate var year: Int { track.year ?? 0 }
  fileprivate var duration: Int { track.totalTime ?? 0 }
  fileprivate var dateadded: String { track.dateAddedISO8601 }
  fileprivate var compilation: Int { (track.compilation ?? false) ? 1 : 0 }
  fileprivate var composer: String { track.composer ?? "" }
  fileprivate var datereleased: String { track.dateReleasedISO8601 }
  fileprivate var comments: String { track.comments ?? "" }
  fileprivate var playdate: String { track.datePlayedISO8601 }
  fileprivate var playcount: Int { track.playCount ?? 0 }

  var insert: Database.Statement {
    """
    INSERT INTO tracks (itunesid, name, sortname, artist, sortartist, album, sortalbum, tracknumber, trackcount, disccount, discnumber, year, duration, dateadded, compilation, composer, datereleased, comments, playdate, playcount)
    VALUES (\(itunesid), \(name), \(sortname), \(artist), \(sortartist), \(album), \(sortalbum), \(tracknumber), \(trackcount), \(disccount), \(discnumber), \(year), \(duration), \(dateadded), \(compilation), \(composer), \(datereleased), \(comments), \(playdate), \(playcount));
    """
  }

  static var insertStatement: Database.Statement {
    FlatTrackRow(track: Track(name: "fake", persistentID: 0)).insert
  }
}
