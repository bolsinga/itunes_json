//
//  Repair.swift
//
//
//  Created by Greg Bolsinga on 12/14/23.
//

import Foundation

struct Repair: Repairing {
  let issues: [Issue]

  public func repair(_ tracks: [Track]) -> [Track] {
    fix(adjustDates(tracks)).filter { $0.isSQLEncodable }.map { $0.pruned }
  }

  private func adjustDates(_ tracks: [Track]) -> [Track] {
    tracks.datesAreAheadOneHour ? tracks.map { $0.moveDatesBackOneHour() } : tracks
  }

  internal func fix(_ tracks: [Track]) -> [Track] {
    let issueTracks = tracks.filter { track in
      !issues.map { $0.criteria }.filter { track.criteriaApplies($0) }.isEmpty
    }
    let noIssueTracks = Array(Set(tracks).subtracting(issueTracks))
    let fixedIssueTracks = issueTracks.compactMap { track in
      var fixedTrack: Track? = track
      issues.forEach {
        if let track = fixedTrack {
          fixedTrack = track.repair($0)
        }
      }
      return fixedTrack
    }
    return fixedIssueTracks + noIssueTracks
  }
}
