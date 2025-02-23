//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

enum Patch: Sendable {
  case missingTitleAlbums([SongArtistAlbum])
  case trackCounts([AlbumTrackCount])
  case trackCorrections([TrackCorrection])
  case trackNumbers([SongTrackNumber])
  case years([SongYear])
  case songs([SongTitleCorrection])
  case identifierCorrections([IdentifierCorrection])
}

extension Patch {
  func addIdentifierCorrections(_ corrections: [IdentifierCorrection]) -> Patch {
    switch self {
    case .identifierCorrections(let array):
      return .identifierCorrections(array + corrections)
    default:
      return self
    }
  }
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
  var description: String {
    switch self {
    case .missingTitleAlbums(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .trackCounts(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .trackCorrections(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .trackNumbers(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .years(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .songs(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .identifierCorrections(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    }
  }
}
