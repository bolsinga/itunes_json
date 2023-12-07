//
//  Destination+Data.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

enum DestinationDataError: Error {
  case sqlNotYetSupported
}

extension Destination {
  public func data(for tracks: [Track]) throws -> Data {
    switch self {
    case .json:
      return try tracks.jsonData()
    case .sqlSource:
      throw DestinationDataError.sqlNotYetSupported
    }
  }
}
