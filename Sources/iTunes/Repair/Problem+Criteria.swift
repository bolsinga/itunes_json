//
//  Problem+Criteria.swift
//
//
//  Created by Greg Bolsinga on 2/8/24.
//

import Foundation

extension Problem {
  var criteria: [Criterion] {
    var result = [Criterion]()

    if let album { result.append(.album(album)) }
    if let artist { result.append(.artist(artist)) }
    if let name { result.append(.song(name)) }

    return result
  }
}
