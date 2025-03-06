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

private enum CorrectionType {
  case duration
  case persistentID
  case dateAdded
  case composer
  case comments
  case dateReleased
  case albumTitle
  case year
  case trackNumber
  case replaceSongTitle
  case discCount
  case discNumber
  case artist
  case play
}

extension IdentityRepair.Correction {
  fileprivate var type: CorrectionType {
    switch self {
    case .duration(_):
      .duration
    case .persistentID(_):
      .persistentID
    case .dateAdded(_):
      .dateAdded
    case .composer(_):
      .composer
    case .comments(_):
      .comments
    case .dateReleased(_):
      .dateReleased
    case .albumTitle(_):
      .albumTitle
    case .year(_):
      .year
    case .trackNumber(_):
      .trackNumber
    case .replaceSongTitle(_):
      .replaceSongTitle
    case .discCount(_):
      .discCount
    case .discNumber(_):
      .discNumber
    case .artist(_):
      .artist
    case .play(_, _):
      .play
    }
  }
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
      // Group IdentityRepairs into groups of same row types.
      for group in Dictionary(grouping: self.identityRepairs, by: { $0.correction.type }) {
        try await dbEncoder.encode(items: group.value)
      }
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
