//
//  IdentityRepair+Database.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

private let duration = "SELECT * FROM 'correct_duration';"
private let persistentID = "SELECT * FROM 'correct_id';"
private let dateAdded = "SELECT * FROM 'correct_added';"
private let composer = "SELECT * FROM 'correct_composer';"
private let comments = "SELECT * FROM 'correct_comment';"
private let dateReleased = "SELECT * FROM 'correct_released';"
private let albumTitle = "SELECT * FROM 'correct_album';"
private let year = "SELECT * FROM 'correct_year';"
private let trackNumber = "SELECT * FROM 'correct_tracknumber';"
private let replaceSongTitle = "SELECT * FROM 'correct_song';"
private let discCount = "SELECT * FROM 'correct_disccount';"
private let discNumber = "SELECT * FROM 'correct_discnumber';"
private let artist = "SELECT * FROM 'correct_artist';"
private let play = "SELECT * FROM 'correct_play';"

private let statementConverters =
  [
    (duration, IdentityRepair.duration(row:)),
    (persistentID, IdentityRepair.persistentID(row:)),
    (dateAdded, IdentityRepair.dateAdded(row:)),
    (composer, IdentityRepair.composer(row:)),
    (comments, IdentityRepair.comments(row:)),
    (dateReleased, IdentityRepair.dateReleased(row:)),
    (albumTitle, IdentityRepair.albumTitle(row:)),
    (year, IdentityRepair.year(row:)),
    (trackNumber, IdentityRepair.trackNumber(row:)),
    (replaceSongTitle, IdentityRepair.replaceSongTitle(row:)),
    (discCount, IdentityRepair.discCount(row:)),
    (discNumber, IdentityRepair.discNumber(row:)),
    (artist, IdentityRepair.artist(row:)),
    (play, IdentityRepair.play(row:)),
  ]

extension Database {
  func identityRepairs() throws -> [IdentityRepair] {
    let corrections = try statementConverters.flatMap { pair in
      let (statement, converter) = pair
      return try execute(query: statement, arguments: []).flatMap {
        $0.compactMap { converter($0) }
      }
    }
    close()
    return corrections
  }
}
