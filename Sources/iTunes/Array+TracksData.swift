//
//  Array+TracksData.swift
//
//
//  Created by Greg Bolsinga on 12/7/23.
//

import Foundation

enum DataExportError: Error {
  case noTracks
}

extension Array where Element == Track {
  func data(for destination: Destination) throws -> Data {
    guard self.count > 0 else {
      throw DataExportError.noTracks
    }

    return try destination.data(for: self)
  }
}
