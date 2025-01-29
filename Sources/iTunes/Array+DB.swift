//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension DatabaseContext {
  fileprivate var context: Database.Context {
    Database.Context(storage: storage, loggingToken: loggingToken)
  }
}

extension Array where Element == Track {
  func database(_ context: DatabaseContext) async throws -> Database {
    let dbEncoder = try TracksDBEncoder(
      context: context.context, rowEncoder: self.rowEncoder(context.loggingToken))
    do {
      try await dbEncoder.encode(schemaOptions: context.schemaOptions)
      return dbEncoder.db
    } catch {
      await dbEncoder.close()
      throw error
    }
  }

  func database(_ context: DatabaseContext) async throws -> Data {
    let db: Database = try await database(context)
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
