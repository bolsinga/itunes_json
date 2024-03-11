//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  public func database(file: URL, loggingToken: String?) async throws {
    let encoder = try DBEncoder(
      file: file, rowEncoder: self.rowEncoder(loggingToken), loggingToken: loggingToken)
    try await encoder.encode()
  }
}
