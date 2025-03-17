//
//  URL+Helpers.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 3/16/25.
//

import Foundation

extension URL {
  var filename: String {
    self.lastPathComponent
  }

  var parentDirectory: URL {
    self.deletingLastPathComponent()
  }
}
