//
//  Destination+FileNameExtension.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Destination {
  var filenameExtension: String {
    switch self {
    case .json:
      "json"
    case .sqlSource:
      "sql"
    }
  }
}
