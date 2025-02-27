//
//  IdentifierCorrection+Database.swift
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
    (duration, IdentifierCorrection.duration(row:)),
    (persistentID, IdentifierCorrection.persistentID(row:)),
    (dateAdded, IdentifierCorrection.dateAdded(row:)),
    (composer, IdentifierCorrection.composer(row:)),
    (comments, IdentifierCorrection.comments(row:)),
    (dateReleased, IdentifierCorrection.dateReleased(row:)),
    (albumTitle, IdentifierCorrection.albumTitle(row:)),
    (year, IdentifierCorrection.year(row:)),
    (trackNumber, IdentifierCorrection.trackNumber(row:)),
    (replaceSongTitle, IdentifierCorrection.replaceSongTitle(row:)),
    (discCount, IdentifierCorrection.discCount(row:)),
    (discNumber, IdentifierCorrection.discNumber(row:)),
    (artist, IdentifierCorrection.artist(row:)),
    (play, IdentifierCorrection.play(row:)),
  ]

extension Database {
  func identifierCorrections() throws -> [IdentifierCorrection] {
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
