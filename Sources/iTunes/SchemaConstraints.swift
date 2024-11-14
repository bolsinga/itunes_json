//
//  SchemaConstraints.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/14/24.
//

import Foundation

/// The constraints to use for the DB schema.
public enum SchemaConstraints: CaseIterable, Sendable {
  /// Emit DB tables with strict schema.
  case strict
  /// Emit DB tables with lax schema. Used for tools to assist massaging the data.
  case lax
}
