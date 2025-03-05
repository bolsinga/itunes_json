//
//  Track+IdentifierCorrection.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/2/25.
//

import Foundation

extension Track {
  func identifierCorrection(_ correction: IdentifierCorrection.Correction) -> IdentifierCorrection {
    IdentifierCorrection(persistentID: persistentID, correction: correction)
  }
}
