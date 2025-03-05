//
//  Track+IdentityRepair.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/2/25.
//

import Foundation

extension Track {
  func identityRepair(_ correction: IdentityRepair.Correction) -> IdentityRepair {
    IdentityRepair(persistentID: persistentID, correction: correction)
  }
}
