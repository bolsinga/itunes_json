//
//  Problem+Criteria.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

extension Problem {
  var criteria: Set<Criterion> {
    var result = Set<Criterion>()

    if let album { result.insert(.album(album)) }
    if let artist { result.insert(.artist(artist)) }
    if let name { result.insert(.song(name)) }
    if let playCount { result.insert(.playCount(playCount)) }

    return result
  }
}
