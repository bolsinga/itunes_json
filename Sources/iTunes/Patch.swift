//
//  Patch.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/24.
//

import Foundation

enum Patch: Sendable {
  case identifierCorrections([IdentifierCorrection])
}

extension Patch: CustomStringConvertible {
  var description: String {
    switch self {
    case .identifierCorrections(let items):
      return (try? (try? items.jsonData())?.asUTF8String()) ?? ""
    }
  }
}
