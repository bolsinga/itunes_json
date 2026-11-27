//
//  CatalogFinding.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

/// What the catalog rules noticed while reducing a snapshot. See RFC 0005, "Catalog rules".
enum CatalogFindingCode: String, CaseIterable, Comparable, Sendable {
  case invalidTrack
  case duplicatePersistentID
  case sortNameConflict
  case sortNameFilled

  static func < (lhs: CatalogFindingCode, rhs: CatalogFindingCode) -> Bool {
    let all = CatalogFindingCode.allCases
    return all.firstIndex(of: lhs)! < all.firstIndex(of: rhs)!
  }
}

struct CatalogFinding: Hashable, Sendable {
  /// The track the finding is about. Nil when it is about an artist.
  let persistentID: UInt?
  let code: CatalogFindingCode
  let detail: String
}
