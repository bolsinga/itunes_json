//
//  RepairDestination.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/23/25.
//

import Foundation

enum RepairDestination {
  case standardOut
  case database(URL)
}

extension Patch {
  fileprivate var identityRepairs: [IdentityRepair] {
    switch self {
    case .identityRepairs(let items):
      return items
    }
  }

  fileprivate func writeDatabase(to url: URL) async throws {
    let dbEncoder = try FlatDBEncoder(context: CorrectionsDBContext(storage: .file(url)))
    do {
      try await dbEncoder.encode(items: self.identityRepairs)
      await dbEncoder.close()
    } catch {
      await dbEncoder.close()
      throw error
    }
  }
}

extension RepairDestination {
  func emit(_ patch: Patch) async throws {
    switch self {
    case .standardOut:
      print(patch)
    case .database(let url):
      try await patch.writeDatabase(to: url)
    }
  }
}
