//
//  DatabaseContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

struct DatabaseContext {
  let storage: DatabaseStorage
  let schemaOptions: SchemaOptions
  let loggingToken: String?
  let serializeDatabaseQueries: Bool

  internal init(
    storage: DatabaseStorage, schemaOptions: SchemaOptions, loggingToken: String? = nil,
    serializeDatabaseQueries: Bool = false
  ) {
    self.storage = storage
    self.schemaOptions = schemaOptions
    self.loggingToken = loggingToken
    self.serializeDatabaseQueries = serializeDatabaseQueries
  }
}
