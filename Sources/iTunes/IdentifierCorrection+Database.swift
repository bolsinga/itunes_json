//
//  IdentifierCorrection+Database.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

private var duration: String { "SELECT * FROM 'correct_duration';" }
private var persistentID: String { "SELECT * FROM 'correct_id';" }
private var dateAdded: String { "SELECT * FROM 'correct_added';" }
private var composer: String { "SELECT * FROM 'correct_composer';" }
private var comments: String { "SELECT * FROM 'correct_comment';" }
private var dateReleased: String { "SELECT * FROM 'correct_released';" }
private var albumTitle: String { "SELECT * FROM 'correct_album';" }
private var year: String { "SELECT * FROM 'correct_year';" }
private var trackNumber: String { "SELECT * FROM 'correct_tracknumber';" }
private var replaceSongTitle: String { "SELECT * FROM 'correct_song';" }
private var discCount: String { "SELECT * FROM 'correct_disccount';" }
private var discNumber: String { "SELECT * FROM 'correct_discnumber';" }
private var artist: String { "SELECT * FROM 'correct_artist';" }
private var play: String { "SELECT * FROM 'correct_play';" }

private var statementConverters: [(String, (Database.Row) -> IdentifierCorrection?)] {
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
}

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
