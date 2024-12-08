//
//  Decodable+Array.swift
//
//
//  Created by Greg Bolsinga on 12/11/23.
//

import Foundation

private enum JSONDecodingError: Error {
  case stringEncodingError
}

extension Decodable {
  static public func array(from url: URL) throws -> [Self] {
    try array(from: try Data(contentsOf: url, options: .mappedIfSafe))
  }

  static public func array(from data: Data) throws -> [Self] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([Self].self, from: data)
  }

  static public func array(from source: String) throws -> [Self] {
    guard let data = source.data(using: .utf8) else { throw JSONDecodingError.stringEncodingError }

    return try array(from: data)
  }
}
