//
//  Patch+URL.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/25/25.
//

import Foundation

extension Array where Element: Codable {
  static fileprivate func load(from url: URL) throws -> Self {
    try load(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static fileprivate func load(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Self.self, from: data)
  }
}

extension Patch {
  static func load(_ url: URL) throws -> Patch {
    let corrections = try Array<IdentifierCorrection>.load(from: url)
    return .identifierCorrections(corrections)
  }
}
