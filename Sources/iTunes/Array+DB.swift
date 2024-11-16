//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  public func database(file: URL, loggingToken: String?, schemaConstrainsts: SchemaConstraints)
    async throws
  {
    var encoder: TracksDBEncoder?
    do {
      encoder = try TracksDBEncoder(
        file: file, rowEncoder: self.rowEncoder(loggingToken), loggingToken: loggingToken)
      try await encoder?.encode(schemaConstrainsts: schemaConstrainsts)
      await encoder?.close()
    } catch {
      await encoder?.close()
      throw error
    }
  }
}
