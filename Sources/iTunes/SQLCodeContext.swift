//
//  SQLCodeContext.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/28/25.
//

import Foundation

struct SQLCodeContext: TracksSQLSourceEncoderContext {
  let output: Output
  let schemaOptions: SchemaOptions
  let loggingToken: String?
}
