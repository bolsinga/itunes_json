//
//  AlbumCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/12/24.
//

import Foundation

struct AlbumCorrection: Codable, Sendable {
  let rename: [String: String]
  let compilation: Set<String>

  init(rename: [String: String] = [:], compilation: Set<String> = []) {
    self.rename = rename
    self.compilation = compilation
  }
}
