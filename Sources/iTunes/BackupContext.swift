//
//  BackupContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/2/25.
//

import Foundation

struct BackupContext: Sendable {
  static let defaultTag = "iTunes"

  let branch: String
  let tagPrefix: String
  let version: String
}
