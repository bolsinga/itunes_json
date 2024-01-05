//
//  DBEncoder.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

final class DBEncoder {
  let db: Database

  init(file: URL) throws {
    self.db = try Database(file: file)
  }

  func encode(_ tracks: [Track]) async throws {

  }
}
