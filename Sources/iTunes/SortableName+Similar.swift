//
//  SortableName+Similar.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/1/24.
//

extension SortableName: Similar {
  public var cullable: Bool {
    sorted.isEmpty
  }

  public func isSimilar(to other: SortableName) -> Bool {
    self.name.isSimilar(to: other.name)
  }
}
