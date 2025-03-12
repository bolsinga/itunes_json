//
//  Backup.swift
//
//
//  Created by Greg Bolsinga on 4/2/24.
//

import Foundation

enum Backup {
  case noChanges
  case changes
}

extension Backup {
  func backupName(baseName: String, existingNames: [String]) -> String {
    let backupName = baseName.calculateBackupName(from: existingNames)
    switch self {
    case .noChanges:
      return backupName.emptyTag
    case .changes:
      return backupName
    }
  }
}
