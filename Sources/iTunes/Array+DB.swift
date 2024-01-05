//
//  Array+DB.swift
//
//
//  Created by Greg Bolsinga on 1/2/24.
//

import Foundation

extension Array where Element == Track {
  public func database(file: URL) async throws {
    let encoder = try DBEncoder(file: file)
    try await encoder.encode(self)
  }
}
