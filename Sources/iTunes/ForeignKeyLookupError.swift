//
//  ForeignKeyLookupError.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/26/26.
//

import Foundation

/// A row whose artist or album was not in the lookup of ids written by an earlier table. The
/// tables are built from the same tracks, so this means the builders disagree.
struct ForeignKeyLookupError: Error, CustomStringConvertible {
  let table: String
  let row: String
  let parent: String

  var description: String {
    "The \(table) row \(row) has no \(parent) row to refer to."
  }
}
