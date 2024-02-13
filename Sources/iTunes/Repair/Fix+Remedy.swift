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

    if let sortArtist { result.insert(.repairSortArtist(sortArtist)) }
    if let kind { result.insert(.repairEmptyKind(kind)) }
    if let year { result.insert(.repairEmptyYear(year)) }
    if let trackCount { result.insert(.repairEmptyTrackCount(trackCount)) }
    if let trackNumber { result.insert(.repairEmptyTrackNumber(trackNumber)) }
    if let album { result.insert(.repairEmptyAlbum(album)) }
    if let artist { result.insert(.replaceArtist(artist)) }
    if let playCount { result.insert(.replacePlayCount(playCount)) }
    if let playDate { result.insert(.replacePlayDate(playDate)) }

    return result
  }
}
