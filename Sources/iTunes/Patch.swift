//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

typealias ArtistPatchLookup = [SortableName: SortableName]
typealias AlbumPatchLookup = [AlbumArtistName: AlbumArtistName]

enum Patch: Sendable {
  case artists(ArtistPatchLookup)
  case albums(AlbumPatchLookup)
  case missingTitleAlbums([SongArtistAlbum])
  case trackCounts([AlbumTrackCount])
  case trackCorrections([TrackCorrection])
  case trackNumbers([SongTrackNumber])
  case years([SongYear])
  case songs([SongTitleCorrection])
  case identifierCorrections([IdentifierCorrection])
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
    case .artists(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    case .albums(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
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
