//
//  GitBackup.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import Foundation

enum GitBackup {
  case noChanges
  case changes
}

extension GitBackup {
  fileprivate func calculateBackupName(baseName: String, existingNames: [String]) -> String {
    let existingBaseNames = existingNames.filter { $0.starts(with: baseName) }.sorted().reversed()
    guard !existingBaseNames.isEmpty else { return baseName }
    return existingBaseNames.first!.nextTag
  }

  func backupName(baseName: String, existingNames: [String]) -> String {
    let backupName = calculateBackupName(baseName: baseName, existingNames: existingNames)
    switch self {
    case .noChanges:
      return backupName.emptyTag
    case .changes:
      return backupName
    }
  }
}
