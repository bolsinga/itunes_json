//
//  Array+Tagged.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/17/25.
//

extension Array where Element: Tagged {
  var initialTag: String? {
    self.sorted(by: { $0.tag < $1.tag }).first?.tag
  }
}
