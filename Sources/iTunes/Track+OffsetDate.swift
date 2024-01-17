//
//  Track+OffsetDate.swift
//
//
//  Created by Greg Bolsinga on 12/23/23.
//

import Foundation

extension Double {
  // "2004-02-04T23:32:22Z"
  static var timeIntervalSince1970ValidSentinel: Double { Double(1_075_937_542) }
}

extension Track {
  var isValidDateCheckSentinel: Bool {
    // "Yesterday" by Chet Atkins has not been played since before this data has been saved.
    persistentID == 17_859_820_717_873_205_520
  }
}
