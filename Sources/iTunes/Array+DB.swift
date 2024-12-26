//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  func database(
    storage: DatabaseStorage, loggingToken: String?, schemaOptions: SchemaOptions
  ) async throws -> Data {
    let dbEncoder = try TracksDBEncoder(
      storage: storage, rowEncoder: self.rowEncoder(loggingToken), loggingToken: loggingToken)
    do {
      try await dbEncoder.encode(schemaOptions: schemaOptions)
      let data = try await dbEncoder.data()
      await dbEncoder.close()
      return data
    } catch {
      await dbEncoder.close()
      throw error
    }
  }
}
