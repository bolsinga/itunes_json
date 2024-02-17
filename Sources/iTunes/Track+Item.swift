//
//  Track+Item.swift
//
//
//  Created by Greg Bolsinga on 2/16/24.
//

import Foundation

extension TrackRow {
  fileprivate func itemWithFixPlayDate(_ playDate: Date) -> Item {
    Item(problem: problem, fix: Fix(playDate: playDate))
  }

  fileprivate var problem: Problem {
    Problem(
      artist: self.artist.name.name, album: self.album.name.name, name: self.song.name.name,
      playCount: self.play != nil ? self.play!.delta : nil,
      playDate: self.play != nil ? ISO8601DateFormatter().date(from: self.play!.date) : nil)
  }
}

extension Track {
  func itemWithFixPlayDate(_ playDate: Date) -> Item {
    trackRow.itemWithFixPlayDate(playDate)
  }
}
