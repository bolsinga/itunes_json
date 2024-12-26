//
//  SchemaOptions.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/25/24.
//

import Foundation

struct SchemaOptions: OptionSet {
  let rawValue: UInt

  private static let laxArtist = SchemaOptions(rawValue: 1 << 0)
  private static let laxAlbum = SchemaOptions(rawValue: 1 << 1)
  private static let laxSong = SchemaOptions(rawValue: 1 << 2)
  private static let laxPlays = SchemaOptions(rawValue: 1 << 3)

  static let strictSchema = SchemaOptions()
  static let laxSchema: SchemaOptions = [
    Self.laxArtist, Self.laxAlbum, Self.laxSong, Self.laxPlays,
  ]

  var artistConstraints: SchemaConstraints { self.contains(.laxArtist) ? .lax : .strict }
  var albumConstraints: SchemaConstraints { self.contains(.laxAlbum) ? .lax : .strict }
  var songConstraints: SchemaConstraints { self.contains(.laxSong) ? .lax : .strict }
  var playsConstraints: SchemaConstraints { self.contains(.laxPlays) ? .lax : .strict }
}
