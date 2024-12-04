//
//  ArtistPatch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/20/24.
//

import Foundation

public struct ArtistPatch: Codable, Comparable, Hashable, Sendable {
  let invalid: SortableName
  let valid: SortableName

  public init(invalid: SortableName, valid: SortableName) {
    self.invalid = invalid
    self.valid = valid
  }

  public static func < (lhs: ArtistPatch, rhs: ArtistPatch) -> Bool {
    lhs.invalid < rhs.invalid
  }
}

extension ArtistPatch: CustomStringConvertible {
  public var description: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(self) else { return "" }
    return (try? data.asUTF8String()) ?? ""
  }
}
