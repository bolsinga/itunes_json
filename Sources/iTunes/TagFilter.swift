//
//  TagFilter.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/8/25.
//

import ArgumentParser

enum TagFilter {
  case ordered
  case stamped
}

extension TagFilter: EnumerableFlag {}
