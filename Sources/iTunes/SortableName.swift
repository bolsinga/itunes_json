//
//  SortableName.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

struct SortableName: Hashable {
  let name: String
  let sorted: String

  init(name: String = "", sorted: String = "") {
    self.name = name
    self.sorted = (name != sorted) ? sorted : ""
  }
}
