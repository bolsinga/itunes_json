//
//  RepairableName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/20/24.
//

import Foundation

struct RepairableArtist: Codable, Hashable, Sendable {
  let invalid: SortableName
  let valid: SortableName?
}
