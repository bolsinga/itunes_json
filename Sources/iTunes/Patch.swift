//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

public typealias ArtistPatchLookup = [SortableName: SortableName]
public typealias AlbumPatchLookup = [AlbumArtistName: AlbumArtistName]

public enum Patch: Sendable {
  case artists(ArtistPatchLookup)
  case albums(AlbumPatchLookup)
}

// This will make a Dictionary<Key, Value> into Array<Key> where each Array
//   element is a Key followed by a Value
// This array of pairs is how JSON encodes a dictionary, but this code ensures
//   the keys are always sorted via the pair's Key in the output. This provides stable output.
extension Dictionary where Key: Codable & Comparable, Value: Codable & Comparable, Key == Value {
  fileprivate func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let items = self.map { $0 }.sorted(by: { $0 < $1 }).flatMap { [$0.0, $0.1] }
    return try encoder.encode(items)
  }
}

extension Patch: CustomStringConvertible {
  public var description: String {
    switch self {
    case .artists(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    }
  }
}
