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

    return []
  }
}

extension Problem {
  var criteria: [Criterion] {
    var result = [Criterion]()

    if let artist { result.append(.artist(artist)) }
    if let name { result.append(.song(name)) }

    return result
  }
}
