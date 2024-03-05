//
//  Array+TracksSqlData.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Array where Element == Track {
  public func sqlData(loggingToken: String?) throws -> Data {
    let encoder = SQLSourceEncoder()
    return try encoder.encode(self, loggingToken: loggingToken)
  }
}
