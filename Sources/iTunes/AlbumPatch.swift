//
//  AlbumPatch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

public struct AlbumPatch: Codable, Comparable, Hashable, Sendable {
  let invalid: AlbumArtistName
  let valid: AlbumArtistName

  public init(invalid: AlbumArtistName, valid: AlbumArtistName) {
    self.invalid = invalid
    self.valid = valid
  }

  public static func < (lhs: AlbumPatch, rhs: AlbumPatch) -> Bool {
    lhs.invalid.name < rhs.invalid.name
  }
}

extension AlbumPatch: CustomStringConvertible {
  public var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
