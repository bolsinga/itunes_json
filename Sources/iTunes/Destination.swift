//
//  Destination.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

/// The destination type for the Track data.
public enum Destination: CaseIterable {
  /// Emit a JSON string representing the Tracks.
  case json
  /// Emit SQLite code that represents the Tracks.
  case sqlCode
  /// Emit a sqlite3 database that represents the Tracks.
  case db
}
