//
//  Repair.swift
//
//
//  Created by Greg Bolsinga on 12/14/23.
//

import Foundation

public struct Repair {
  private let items: [Item]

  internal init(items: [Item]) {
    self.items = items
  }

  func repair(_ tracks: [Track]) -> [Track] {
    fix(adjustDates(tracks)).filter { $0.isSQLEncodable }.map { $0.pruned }
  }

  private func adjustDates(_ tracks: [Track]) -> [Track] {
    tracks.datesAreAheadOneHour ? tracks.map { $0.moveDatesBackOneHour() } : tracks
  }

  internal func fix(_ tracks: [Track]) -> [Track] {
    let fixes = tracks.reduce(into: [Track: [Fix]]()) { dictionary, track in
      var arr = dictionary[track] ?? []
      arr.append(
        contentsOf: items.filter { track.matches(problem: $0.problem) }.compactMap { $0.fix })
      if !arr.isEmpty { dictionary[track] = arr }
    }

    guard !fixes.isEmpty else { return tracks }

    return tracks.compactMap { track in
      if let fixes = fixes[track], !fixes.isEmpty {
        var fixedTrack: Track? = track
        fixes.forEach {
          if let repairedTrack: Track = fixedTrack {
            fixedTrack = repairedTrack.repair($0)
          }
        }
        return fixedTrack
      }
      return track
    }
  }
}
