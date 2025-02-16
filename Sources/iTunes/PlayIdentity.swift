//
//  PlayIdentity.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 2/16/25.
//

import Foundation

struct PlayIdentity: Hashable, Identifiable, Sendable {
  var id: UInt { persistentID }
  let persistentID: UInt
  let play: Play
}

extension Track {
  var playIdentity: PlayIdentity { PlayIdentity(persistentID: persistentID, play: play) }
}
