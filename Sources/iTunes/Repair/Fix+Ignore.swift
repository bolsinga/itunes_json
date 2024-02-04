//
//  Fix+Ignore.swift
//
//
//  Created by Greg Bolsinga on 2/3/24.
//

import Foundation

extension Fix {
  /// Tests to see if ignore Fix is exclusive and has no other fixes to apply.
  internal var validateIgnoreFix: Bool {
    guard album == nil, artist == nil, playCount == nil, playDate == nil, sortArtist == nil,
      trackCount == nil, trackNumber == nil, year == nil
    else { return false }
    return true
  }

  var trackIgnored: Bool {
    guard let ignore else { return false }

    guard validateIgnoreFix else {
      preconditionFailure("Fix for kind has other properties set. \(self)")
    }

    return ignore
  }
}
