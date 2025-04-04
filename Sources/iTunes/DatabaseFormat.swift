//
//  DatabaseFormat.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

enum DatabaseFormat {
  case normalized(DatabaseContext)
  case flat(FlatTracksDatabaseContext)
}

extension DatabaseFormat {
  var storage: DatabaseStorage {
    switch self {
    case .normalized(let context):
      context.storage
    case .flat(let context):
      context.storage
    }
  }

  var serializeDatabaseQueries: Bool {
    switch self {
    case .normalized(let context):
      context.serializeDatabaseQueries
    case .flat(let context):
      context.serializeDatabaseQueries
    }
  }
}

extension DatabaseContext: TracksDBEncoderContext {
  var context: Database.Context {
    Database.Context(storage: storage, loggingToken: loggingToken)
  }
}

extension Array where Element == Track {
  fileprivate func database(_ context: DatabaseContext) async throws -> Database {
    let dbEncoder = try TracksDBEncoder(
      context: context, rowEncoder: self.rowEncoder(context.loggingToken))
    do {
      try await dbEncoder.encode()
      return dbEncoder.db
    } catch {
      await dbEncoder.close()
      throw error
    }
  }

  fileprivate func databaseData(_ context: DatabaseContext) async throws -> Data {
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

extension Array where Element == Track {
  fileprivate var encodables: [Element] {
    self.filter { $0.isSQLEncodable }
  }
}

extension FlatTracksDatabaseContext {
  fileprivate func flatDatabase(_ tracks: [Track]) async throws -> Database {
    let dbEncoder = try FlatDBEncoder(context: self)
    do {
      try await dbEncoder.encode(items: tracks.encodables)
      return dbEncoder.db
    } catch {
      await dbEncoder.close()
      throw error
    }
  }

  fileprivate func flatDatabaseData(_ tracks: [Track]) async throws -> Data {
    let db: Database = try await flatDatabase(tracks)
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

extension DatabaseFormat {
  func database(tracks: [Track]) async throws -> Database {
    switch self {
    case .normalized(let context):
      try await tracks.database(context)
    case .flat(let context):
      try await context.flatDatabase(tracks)
    }
  }

  func databaseData(tracks: [Track]) async throws -> Data {
    switch self {
    case .normalized(let context):
      try await tracks.databaseData(context)
    case .flat(let context):
      try await context.flatDatabaseData(tracks)
    }
  }
}
