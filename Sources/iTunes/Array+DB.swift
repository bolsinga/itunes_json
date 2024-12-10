//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  func database(
    storage: DatabaseStorage, loggingToken: String?, schemaConstrainsts: SchemaConstraints
  ) async throws {
    let dbEncoder = try TracksDBEncoder(
      storage: storage, rowEncoder: self.rowEncoder(loggingToken), loggingToken: loggingToken)
    do {
      try await dbEncoder.encode(schemaConstrainsts: schemaConstrainsts)
      await dbEncoder.close()
    } catch {
      await dbEncoder.close()
      throw error
    }
  }
}
