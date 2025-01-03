//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

typealias ArtistPatchLookup = [SortableName: SortableName]
typealias AlbumPatchLookup = [AlbumArtistName: AlbumArtistName]
typealias AlbumMissingTitlePatchLookup = [SongArtist: SortableName]
typealias AlbumTrackCountLookup = [AlbumArtistName: Int]
typealias SongTrackNumberLookup = [SongArtistAlbum: Int]
typealias SongYearLookup = [SongArtistAlbum: Int]

enum Patch: Sendable {
  case artists(ArtistPatchLookup)
  case albums(AlbumPatchLookup)
  case missingTitleAlbums(AlbumMissingTitlePatchLookup)
  case trackCounts(AlbumTrackCountLookup)
  case trackCorrections([TrackCorrection])
  case trackNumbers(SongTrackNumberLookup)
  case years(SongYearLookup)
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

extension AlbumMissingTitlePatchLookup {
  fileprivate func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    // FIXME: It would be nice to have the dictionary self-sort, like the extension above.
    // The problem is that the key/values are different types.
    return try encoder.encode(self)
  }
}

extension AlbumTrackCountLookup {
  fileprivate func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    // FIXME: It would be nice to have the dictionary self-sort, like the extension above.
    // The problem is that the key/values are different types.
    return try encoder.encode(self)
  }
}

extension Dictionary where Key == SongArtistAlbum, Value == Int {
  fileprivate func jsonData() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    // FIXME: It would be nice to have the dictionary self-sort, like the extension above.
    // The problem is that the key/values are different types.
    return try encoder.encode(self)
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
    }
  }
}
