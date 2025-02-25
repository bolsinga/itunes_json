//
//  RepairDestination.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/23/25.
//

import Foundation

enum RepairDestination {
  case standardOut
}

extension RepairDestination {
  func emit(_ patch: Patch) async throws {
    switch self {
    case .standardOut:
      print(patch)
    }
  }
}
