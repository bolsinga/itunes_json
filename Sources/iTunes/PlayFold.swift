//
//  PlayFold.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 11/27/26.
//

import Foundation

/// What one snapshot shows for one song. A missing count is 0. The date is the ISO 8601 `playDateUTC`.
struct PlayObservation: Hashable, Sendable {
  let count: Int
  let date: String?
}

/// The last count and date the fold accepted as a baseline. `seenDate` is empty only while `seenCount` is 0.
struct PlayState: Hashable, Sendable {
  var seenCount: Int
  var seenDate: String
}

/// The observations the fold does not apply in full.
enum PlayFindingCode: String, CaseIterable, Hashable, Sendable {
  case noPlayDate
  case countUpDateNotForward
  case countReset
  case countDecreased
  case dateForwardNoCount
  case dateBackward
}

/// Enough to apply an observation differently later: the state before, the observation, and what the fold did.
struct PlayFinding: Hashable, Sendable {
  let code: PlayFindingCode
  let before: PlayState?
  let observation: PlayObservation
  let playsAdded: Int
  let after: PlayState?
}

struct PlayStep: Sendable {
  /// The state after the observation. `nil` when the song has never been played.
  let state: PlayState?
  /// The play to add, the last known date and the plays since the previous row.
  let play: (date: String, delta: Int)?
  let finding: PlayFinding?
}

private enum DateOrder {
  /// There is no usable date.
  case empty
  /// Later than the seen date by more than the quirk.
  case forward
  /// Equal to the seen date, up to the quirk.
  case same
  /// Earlier than the seen date by more than the quirk.
  case back
}

extension PlayObservation {
  fileprivate func order(after seenDate: String) -> DateOrder {
    guard let date, let new = ISO8601DateFormatter().date(from: date) else { return .empty }
    // An empty seen date is earlier than any date.
    guard !seenDate.isEmpty, let seen = ISO8601DateFormatter().date(from: seenDate) else {
      return .forward
    }
    switch seen.compareQuirk(new) {
    case .orderedAscending: return .forward
    case .orderedSame, .orderedSameQuirk: return .same
    case .orderedDescending: return .back
    }
  }
}

/// Fold one observation into a song's state, by the nine cases of RFC 0005, in order.
func step(_ state: PlayState?, _ observation: PlayObservation) -> PlayStep {
  let seen = state ?? PlayState(seenCount: 0, seenDate: "")
  let order = observation.order(after: seen.seenDate)
  // A count of 0 with a date is read as one play.
  let c = (order != .empty && observation.count < 1) ? 1 : observation.count

  func result(
    _ code: PlayFindingCode?, state new: PlayState?, play: (date: String, delta: Int)? = nil
  ) -> PlayStep {
    PlayStep(
      state: new, play: play,
      finding: code.map {
        PlayFinding(
          code: $0, before: state, observation: observation, playsAdded: play?.delta ?? 0,
          after: new)
      })
  }

  if state == nil {
    if c > 0 {
      if order == .empty {  // 2
        return result(.noPlayDate, state: PlayState(seenCount: 0, seenDate: ""))
      }
      // 1
      let date = observation.date!
      return result(nil, state: PlayState(seenCount: c, seenDate: date), play: (date, c))
    }
    // Never played, and no state.
    return result(nil, state: nil)
  }

  if c == seen.seenCount {
    switch order {
    case .empty, .same:  // 3
      return result(nil, state: seen)
    case .forward:  // 8
      return result(
        .dateForwardNoCount,
        state: PlayState(seenCount: seen.seenCount, seenDate: observation.date!))
    case .back:  // 9
      return result(.dateBackward, state: seen)
    }
  }

  if c > seen.seenCount {
    if order == .forward {  // 4
      let date = observation.date!
      return result(
        nil, state: PlayState(seenCount: c, seenDate: date), play: (date, c - seen.seenCount))
    }
    return result(.countUpDateNotForward, state: seen)  // 5
  }

  if order == .forward {  // 6
    let date = observation.date!
    return result(
      .countReset, state: PlayState(seenCount: c, seenDate: date), play: (date, max(c, 1)))
  }
  // 7
  return result(.countDecreased, state: PlayState(seenCount: c, seenDate: seen.seenDate))
}
