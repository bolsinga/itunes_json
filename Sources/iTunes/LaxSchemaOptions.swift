//
//  LaxSchemaOptions.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/25/24.
//

import Foundation

struct LaxSchemaOptions: OptionSet {
  let rawValue: UInt

  static let artist = LaxSchemaOptions(rawValue: 1 << 0)
  static let album = LaxSchemaOptions(rawValue: 1 << 1)
  static let song = LaxSchemaOptions(rawValue: 1 << 2)
  static let plays = LaxSchemaOptions(rawValue: 1 << 3)

  static let strictSchema = LaxSchemaOptions()
  static let laxSchema: LaxSchemaOptions = [Self.artist, Self.album, Self.song, Self.plays]

  var artistConstraints: SchemaConstraints { self.contains(.artist) ? .lax : .strict }
  var albumConstraints: SchemaConstraints { self.contains(.album) ? .lax : .strict }
  var songConstraints: SchemaConstraints { self.contains(.song) ? .lax : .strict }
  var playsConstraints: SchemaConstraints { self.contains(.plays) ? .lax : .strict }
}
