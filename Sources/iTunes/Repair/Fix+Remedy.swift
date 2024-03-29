//
//  Fix+Issue.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Fix {
  var remedies: Set<Remedy> {
    if let ignore, ignore { return [Remedy.ignore] }

    var result = Set<Remedy>()

    if let sortArtist { result.insert(.replaceSortArtist(sortArtist)) }
    if let kind { result.insert(.repairEmptyKind(kind)) }
    if let year { result.insert(.repairEmptyYear(year)) }
    if let trackCount { result.insert(.replaceTrackCount(trackCount)) }
    if let trackNumber { result.insert(.repairEmptyTrackNumber(trackNumber)) }
    if let album { result.insert(.replaceAlbum(album)) }
    if let artist { result.insert(.replaceArtist(artist)) }
    if let playCount { result.insert(.replacePlayCount(playCount)) }
    if let playDate { result.insert(.replacePlayDate(playDate)) }
    if let song { result.insert(.replaceSong(song)) }
    if let discCount { result.insert(.replaceDiscCount(discCount)) }
    if let discNumber { result.insert(.replaceDiscNumber(discNumber)) }

    return result
  }
}
