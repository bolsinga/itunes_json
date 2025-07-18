//
//  CorrectionsDBRow.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/23/25.
//

import Foundation

extension IdentityRepair.Correction {
  fileprivate var newitunesid: String? {
    if case .persistentID(let v) = self { String(v) } else { nil }
  }
  fileprivate var name: String? {
    if case .replaceSongTitle(let v) = self { v.name } else { nil }
  }
  fileprivate var sortname: String? {
    if case .replaceSongTitle(let v) = self { v.sorted } else { nil }
  }
  fileprivate var artist: String? {
    if case .artist(let v) = self { v?.name } else { nil }
  }
  fileprivate var sortartist: String? {
    if case .artist(let v) = self { v?.sorted } else { nil }
  }
  fileprivate var album: String? {
    if case .albumTitle(let v) = self { v?.name } else { nil }
  }
  fileprivate var sortalbum: String? {
    if case .albumTitle(let v) = self { v?.sorted } else { nil }
  }
  fileprivate var tracknumber: Int? {
    if case .trackNumber(let v) = self { v } else { nil }
  }
  fileprivate var trackcount: Int? { nil }
  fileprivate var disccount: Int? {
    if case .discCount(let v) = self { v } else { nil }
  }
  fileprivate var discnumber: Int? {
    if case .discNumber(let v) = self { v } else { nil }
  }
  fileprivate var year: Int? {
    if case .trackNumber(let v) = self { v } else { nil }
  }
  fileprivate var duration: Int? {
    if case .trackNumber(let v) = self { v } else { nil }
  }
  fileprivate var dateadded: String? {
    if case .dateAdded(let v) = self { v } else { nil }
  }
  fileprivate var compilation: Int? { nil }
  fileprivate var composer: String? {
    if case .composer(let v) = self { v } else { nil }
  }
  fileprivate var datereleased: String? {
    if case .dateReleased(let v) = self { v } else { nil }
  }
  fileprivate var comments: String? {
    if case .comments(let v) = self { v } else { nil }
  }
  fileprivate var oldplaydate: String? {
    if case .play(let v, _) = self { v.date } else { nil }
  }
  fileprivate var oldplaycount: Int? {
    if case .play(let v, _) = self { v.count } else { nil }
  }
  fileprivate var newplaydate: String? {
    if case .play(_, let v) = self { v.date } else { nil }
  }
  fileprivate var newplaycount: Int? {
    if case .play(_, let v) = self { v.count } else { nil }
  }
}

struct CorrectionsDBRow: FlatRow {
  let repair: IdentityRepair

  fileprivate var itunesid: String { String(repair.persistentID) }
  fileprivate var newitunesid: String? { repair.correction.newitunesid }
  fileprivate var name: String? { repair.correction.name }
  fileprivate var sortname: String? { repair.correction.sortname }
  fileprivate var artist: String? { repair.correction.artist }
  fileprivate var sortartist: String? { repair.correction.sortartist }
  fileprivate var album: String? { repair.correction.album }
  fileprivate var sortalbum: String? { repair.correction.sortalbum }
  fileprivate var tracknumber: Int? { repair.correction.tracknumber }
  fileprivate var trackcount: Int? { repair.correction.trackcount }
  fileprivate var disccount: Int? { repair.correction.disccount }
  fileprivate var discnumber: Int? { repair.correction.discnumber }
  fileprivate var year: Int? { repair.correction.year }
  fileprivate var duration: Int? { repair.correction.duration }
  fileprivate var dateadded: String? { repair.correction.dateadded }
  fileprivate var compilation: Int? { repair.correction.compilation }
  fileprivate var composer: String? { repair.correction.composer }
  fileprivate var datereleased: String? { repair.correction.datereleased }
  fileprivate var comments: String? { repair.correction.comments }
  fileprivate var oldplaydate: String? { repair.correction.oldplaydate }
  fileprivate var oldplaycount: Int? { repair.correction.oldplaycount }
  fileprivate var newplaydate: String? { repair.correction.newplaydate }
  fileprivate var newplaycount: Int? { repair.correction.newplaycount }

  var parameters: [Database.Value] { insert.parameters }

  private var correctID: Database.Statement {
    "INSERT OR IGNORE INTO correct_id (itunesid, value) VALUES (\(itunesid), \(newitunesid));"
  }

  private var correctSong: Database.Statement {
    "INSERT OR IGNORE INTO correct_song (itunesid, name, sort) VALUES (\(itunesid), \(name), \(sortname));"
  }

  private var correctArtist: Database.Statement {
    "INSERT OR IGNORE INTO correct_artist (itunesid, name, sort) VALUES (\(itunesid), \(artist), \(sortartist));"
  }

  private var correctAlbum: Database.Statement {
    "INSERT OR IGNORE INTO correct_album (itunesid, name, sort) VALUES (\(itunesid), \(album), \(sortalbum));"
  }

  private var correctTrackNumber: Database.Statement {
    "INSERT OR IGNORE INTO correct_tracknumber (itunesid, value) VALUES (\(itunesid), \(tracknumber));"
  }

  private var correctTrackCount: Database.Statement {
    "INSERT OR IGNORE INTO correct_trackcount (itunesid, value) VALUES (\(itunesid), \(trackcount));"
  }

  private var correctDiscNumber: Database.Statement {
    "INSERT OR IGNORE INTO correct_discnumber (itunesid, value) VALUES (\(itunesid), \(discnumber));"
  }

  private var correctDiscCount: Database.Statement {
    "INSERT OR IGNORE INTO correct_disccount (itunesid, value) VALUES (\(itunesid), \(disccount));"
  }

  private var correctYear: Database.Statement {
    "INSERT OR IGNORE INTO correct_year (itunesid, value) VALUES (\(itunesid), \(year));"
  }

  private var correctDuration: Database.Statement {
    "INSERT OR IGNORE INTO correct_duration (itunesid, value) VALUES (\(itunesid), \(duration));"
  }

  private var correctAdded: Database.Statement {
    "INSERT OR IGNORE INTO correct_added (itunesid, date) VALUES (\(itunesid), \(dateadded));"
  }

  private var correctCompilation: Database.Statement {
    "INSERT OR IGNORE INTO correct_compilation (itunesid, value) VALUES (\(itunesid), \(compilation));"
  }

  private var correctComposer: Database.Statement {
    "INSERT OR IGNORE INTO correct_composer (itunesid, value) VALUES (\(itunesid), \(composer));"
  }

  private var correctReleased: Database.Statement {
    "INSERT OR IGNORE INTO correct_released (itunesid, date) VALUES (\(itunesid), \(datereleased));"
  }

  private var correctComment: Database.Statement {
    "INSERT OR IGNORE INTO correct_comment (itunesid, value) VALUES (\(itunesid), \(comments));"
  }

  private var correctPlay: Database.Statement {
    "INSERT OR IGNORE INTO correct_play (itunesid, olddate, oldcount, newdate, newcount) VALUES (\(itunesid), \(oldplaydate), \(oldplaycount), \(newplaydate), \(newplaycount));"
  }

  private var insert: Database.Statement {
    switch repair.correction {
    case .duration(_):
      correctDuration
    case .persistentID(_):
      correctID
    case .dateAdded(_):
      correctAdded
    case .composer(_):
      correctComposer
    case .comments(_):
      correctComment
    case .dateReleased(_):
      correctReleased
    case .albumTitle(_):
      correctAlbum
    case .year(_):
      correctYear
    case .trackNumber(_):
      correctTrackNumber
    case .replaceSongTitle(_):
      correctSong
    case .discCount(_):
      correctDiscCount
    case .discNumber(_):
      correctDiscNumber
    case .artist(_):
      correctArtist
    case .play(_, _):
      correctPlay
    }
  }

  static func insertStatement(_ item: IdentityRepair) -> Database.Statement {
    CorrectionsDBRow(repair: item).insert
  }
}
