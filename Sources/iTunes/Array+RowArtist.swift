//
//  Array+RowArtist.swift
//
//
//  Created by Greg Bolsinga on 12/31/23.
//

import Foundation

extension Array where Element == RowArtist {
  var mismatchedSortableNames: [String] {
    self.reduce(into: [String: Int]()) {
      var v = $0[$1.nameOnly] ?? 0
      v += 1
      $0[$1.nameOnly] = v
    }.filter { $0.value > 1 }.map { $0.key }
  }
}
