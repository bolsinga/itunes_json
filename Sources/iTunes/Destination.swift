//
//  Destination.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

/// The destination type for the Track data.
enum Destination {
  /// Emit a JSON string representing the Tracks.
  case json(Output)
  /// Emit JSON representing the Tracks and add to a git repository
  case jsonGit(Output)
  /// Emit SQLite code that represents the Tracks.
  case sqlCode(SQLCodeContext)
  /// Emit a sqlite3 database that represents the Tracks.
  case db(DatabaseStorage)
  /// Update a sqlite3 database that represents the Tracks.
  case updateDB(DatabaseStorage)
}
