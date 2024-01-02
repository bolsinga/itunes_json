//
//  Track+RowKind.swift
//
//
//  Created by Greg Bolsinga on 1/1/24.
//

import Foundation

extension Track {
  var rowKind: RowKind {
    return RowKind(kind: kind ?? "")
  }
}
