//
//  Track+SQLEncodable.swift
//
//
//  Created by Greg Bolsinga on 12/30/23.
//

import Foundation

extension Track {
  fileprivate var isPodcast: Bool {
    guard let podcast else { return false }
    return podcast
  }

  fileprivate var isVoiceMemo: Bool {
    (trackCount == nil && album != nil && kind != nil && album == "Voice Memos"
      && kind == "AAC audio file")
  }

  fileprivate var isATVShow: Bool {
    guard let tVShow else { return false }
    return tVShow
  }

  var isSQLEncodable: Bool {
    guard !isPodcast else { return false }
    guard !isVoiceMemo else { return false }
    guard !isATVShow else { return false }

    let kind: String = kind?.lowercased() ?? ""
    guard !kind.contains(" app") else { return false }
    guard !kind.contains("book") else { return false }
    guard !kind.contains("video") else { return false }
    guard !kind.contains("pdf") else { return false }
    guard !kind.contains("itunes lp") else { return false }
    guard !kind.contains("itunes extras") else { return false }
    guard !kind.contains("internet audio stream") else { return false }
    guard kind != "quicktime movie file" else { return false }

    return true
  }
}
