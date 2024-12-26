//
//  SchemaConstraints+SchemaOptions.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 12/25/24.
//

extension SchemaConstraints {
  var schemaOptions: SchemaOptions {
    switch self {
    case .strict:
      .strictSchema
    case .lax:
      .laxSchema
    }
  }
}
