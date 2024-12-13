//
//  SortableName+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

extension SortableName: Similar {
  var cullable: Bool {
    sorted.isEmpty
  }

  func isSimilar(to other: SortableName) -> Bool {
    self.name.isSimilar(to: other.name)
  }
}
