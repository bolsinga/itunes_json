//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  func database(context: Database.Context, schemaOptions: SchemaOptions) async throws -> Database {
    let dbEncoder = try TracksDBEncoder(
      context: context, rowEncoder: self.rowEncoder(context.loggingToken))
    do {
      try await dbEncoder.encode(schemaOptions: schemaOptions)
      return dbEncoder.db
    } catch {
      await dbEncoder.close()
      throw error
    }
  }

  func database(context: Database.Context, schemaOptions: SchemaOptions) async throws -> Data {
    let db: Database = try await database(context: context, schemaOptions: schemaOptions)
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
