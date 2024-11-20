//
//  RepairableName.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/20/24.
//

import Foundation

struct RepairableName: Codable, Hashable {
  let invalid: SortableName
  let valid: SortableName?
}
