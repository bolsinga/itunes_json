//
//  SchemaFlag.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/25/24.
//

import ArgumentParser
import Foundation

enum SchemaFlag: String, EnumerableFlag {
  case laxArtists, laxAlbums, laxSongs, laxPlays
}

extension SchemaFlag {
  var schemaOption: SchemaOptions {
    switch self {
    case .laxArtists:
      .laxArtist
    case .laxAlbums:
      .laxAlbum
    case .laxSongs:
      .laxSong
    case .laxPlays:
      .laxPlays
    }
  }
}

extension Collection where Element == SchemaFlag {
  var schemaOptions: SchemaOptions {
    self.reduce(into: SchemaOptions()) { partialResult, flag in
      partialResult.insert(flag.schemaOption)
    }
  }
}
