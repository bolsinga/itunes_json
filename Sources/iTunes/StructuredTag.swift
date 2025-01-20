//
//  StructuredTag.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 1/7/25.
//

import Foundation

struct StructuredTag: Comparable, CustomStringConvertible {
  let root: String  // "iTunes" from iTunes-V12-2025-01-01
  let version: Int  // "12" from iTunes-V12-2025-01-01
  let stamp: String  // "2025-01-01" from iTunes-V12-2025-01-01

  static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.root != rhs.root {
      return lhs.root < rhs.root
    }
    if lhs.version != rhs.version {
      return lhs.version < rhs.version
    }
    return lhs.stamp < rhs.stamp
  }

  var description: String {
    "\(root)-V\(version)-\(stamp)"
  }

  var next: StructuredTag {
    StructuredTag(root: root, version: version + 1, stamp: stamp)
  }
}
