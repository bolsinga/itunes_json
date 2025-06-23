//
//  Array+Codable.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

extension Array where Element: Codable {
  func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(self)
  }
}
