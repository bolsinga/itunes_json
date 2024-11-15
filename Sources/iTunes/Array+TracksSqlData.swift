//
//  Array+TracksSqlData.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Array where Element == Track {
  public func sqlData(loggingToken: String?, schemaConstraints: SchemaConstraints) throws -> Data {
    let encoder = TracksSQLSourceEncoder()
    return try encoder.encode(
      self, loggingToken: loggingToken, schemaConstraints: schemaConstraints)
  }
}
