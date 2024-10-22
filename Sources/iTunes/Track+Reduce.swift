//
//  Track+Reduce.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 10/21/24.
//

import Foundation

extension Track {
  var reducedTrack: Track? {
    guard self.isSQLEncodable else { return nil }
    return self.pruned
  }
}
