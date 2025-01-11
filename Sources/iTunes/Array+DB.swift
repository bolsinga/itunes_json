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
  ) async throws -> Database {
    let dbEncoder = try TracksDBEncoder(
      storage: storage, rowEncoder: self.rowEncoder(loggingToken), loggingToken: loggingToken)
    do {
      try await dbEncoder.encode(schemaOptions: schemaOptions)
      return dbEncoder.db
    } catch {
      await dbEncoder.close()
      throw error
    }
  }

  func database(
    storage: DatabaseStorage, loggingToken: String?, schemaOptions: SchemaOptions
  ) async throws -> Data {
    let db: Database = try await database(
      storage: storage, loggingToken: loggingToken, schemaOptions: schemaOptions)
    do {
      let data = try await db.data()
      await db.close()
      return data
    } catch {
      await db.close()
      throw error
    }
  }
}
