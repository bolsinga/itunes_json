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
    fix(adjustDates(tracks))
  }

  private func adjustDates(_ tracks: [Track]) -> [Track] {
    tracks.datesAreAheadOneHour ? tracks.map { $0.moveDatesBackOneHour() } : tracks
  }

  internal func fix(_ tracks: [Track]) -> [Track] {
    let details = tracks.reduce(into: [Track: [Issue]]()) { partialResult, track in
      let applicableIssues = issues.filter { track.criteriaApplies($0.criteria) }
      partialResult[track] = !applicableIssues.isEmpty ? applicableIssues : []
    }

    return tracks.compactMap { track in
      if let issues = details[track], !issues.isEmpty {
        var fixedTrack: Track? = track
        issues.forEach { issue in
          if let repairedTrack: Track = fixedTrack {
            fixedTrack = repairedTrack.repair(issue)
          }
        }
        return fixedTrack
      }
      return track
    }
  }
}
