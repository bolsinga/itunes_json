//
//  Array+TracksDuplicatePlayDate.swift
//
//
//  Created by Greg Bolsinga on 2/16/24.
//

import Foundation

extension Array where Element == Track {
  func duplicatePlayDateItems(_ loggingToken: String?) -> [Item] {
    // group by playdate. find those with more than one Track.
    let duplicates = Dictionary(grouping: self.filter { $0.playDateUTC != nil }) { $0.playDateUTC! }
      .filter { $0.value.count > 1 }

    return duplicates.flatMap {
      var date = $0
      return $1.reduce(into: [Item]()) {
        // Bump the date of everything by one more second so they are unique.
        date = date.addingTimeInterval(1)
        $0.append($1.itemWithFixPlayDate(date, loggingToken: loggingToken))
      }
    }
  }
}
