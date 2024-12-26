//
//  SchemaFlag.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/25/24.
//

import ArgumentParser
import Foundation

enum SchemaFlag: String, EnumerableFlag {
  case artists, albums, songs, plays
}

extension SchemaFlag {
  var schemaOption: SchemaOptions {
    switch self {
    case .artists:
      .laxArtist
    case .albums:
      .laxAlbum
    case .songs:
      .laxSong
    case .plays:
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
