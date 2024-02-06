//
//  Fix+Issue.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Fix {
  var remedies: [Remedy] {
    if let ignore, ignore { return [Remedy.ignore] }

    var result = [Remedy]()

    if let sortArtist { result.append(.correctSortArtist(sortArtist)) }
    if let kind { result.append(.correctKind(kind)) }
    if let year { result.append(.correctYear(year)) }
    if let trackCount { result.append(.correctTrackCount(trackCount)) }
    if let album { result.append(.correctAlbum(album)) }
    if let artist { result.append(.correctArtist(artist)) }

    return result
  }
}

extension Problem {
  var criteria: [Criterion] {
    var result = [Criterion]()

    if let album { result.append(.album(album)) }
    if let artist { result.append(.artist(artist)) }
    if let name { result.append(.song(name)) }

    return result
  }
}
