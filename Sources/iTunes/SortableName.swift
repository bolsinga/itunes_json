//
//  SortableName.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct SortableName: Hashable {
  @QuoteEscaped var name: String
  @QuoteEscaped var sorted: String

  init(name: String = "", sorted: String = "") {
    self.name = name
    self.sorted = (name != sorted) ? sorted : ""
  }
}
