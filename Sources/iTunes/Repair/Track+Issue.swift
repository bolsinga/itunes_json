//
//  Track+Repair.swift
//
//
//  Created by Greg Bolsinga on 2/1/24.
//

import Foundation

extension Track {
  internal func criterionApplies(_ criterion: Criterion) -> Bool {
    switch criterion {
    case .artist(let string):
      guard let artist else { return false }
      return artist == string
    case .song(let string):
      return name == string
    }
  }

  internal func criteriaApplies(_ criteria: [Criterion]) -> Bool {
    for criterion in criteria {
      guard criterionApplies(criterion) else { return false }
    }
    return true
  }

  internal func applyRemedy(_ remedy: Remedy) -> Track? {
    switch remedy {
    case .ignore:
      return nil
    }
  }

  func repair(_ issue: Issue) -> Track? {
    guard issue.isValid else { return self }
    guard criteriaApplies(issue.critera) else { return self }

    var fixedTrack: Track? = self
    for remedy in issue.remedies {
      fixedTrack = fixedTrack?.applyRemedy(remedy)
    }
    return fixedTrack
  }
}
