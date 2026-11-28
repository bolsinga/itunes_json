//
//  TagOrder.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/29/26.
//

import Foundation

/// The order of the snapshots of the repository: the order of `StructuredTag`, which is the order
/// `Array<String>.stampOrderedMatching` sorts the tags in. A tag that is not a structured tag
/// is ordered by its string.
enum TagOrder {
  static func isOrderedBefore(_ lhs: String, _ rhs: String) -> Bool {
    let parser = TagParser()
    guard let lhsTag = parser.structuredTag(lhs), let rhsTag = parser.structuredTag(rhs) else {
      return lhs < rhs
    }
    return lhsTag < rhsTag
  }
}

extension Array where Element == String {
  /// The tags that are snapshots, one for each stamp, in tag order, and only those after `tag` if
  /// there is one.
  func stampOrderedMatching(after tag: String?) -> [Element] {
    let tags = stampOrderedMatching
    guard let tag else { return tags }
    return tags.filter { TagOrder.isOrderedBefore(tag, $0) }
  }
}
