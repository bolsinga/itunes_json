//
//  Array+ItemJsonData.swift
//
//
//  Created by Greg Bolsinga on 2/16/24.
//

import Foundation

extension Array where Element == Item {
  internal func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    return try encoder.encode(self)
  }
}
