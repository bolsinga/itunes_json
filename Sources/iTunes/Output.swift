//
//  Output.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/8/24.
//

import Foundation

enum Output {
  /// Create a new file at URL
  case file(URL)
  /// Write to standard out.
  case standardOut

  var url: URL? {
    switch self {
    case .file(let url):
      return url
    case .standardOut:
      return nil
    }
  }
}
