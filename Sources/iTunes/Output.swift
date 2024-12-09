//
//  Output.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/8/24.
//

import Foundation

public enum Output {
  case file(URL)
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
