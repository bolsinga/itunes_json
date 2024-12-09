//
//  DatabaseStorage.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/10/24.
//

import Foundation

public enum DatabaseStorage: Sendable {
  case file(URL)
  case memory

  var name: String {
    switch self {
    case .file(let url):
      url.absoluteString
    case .memory:
      ":memory:"
    }
  }
}
